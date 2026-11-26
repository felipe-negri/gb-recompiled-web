// Battery saves and RTC data are written to /saves (platform_sdl.cpp); back it with IndexedDB.
Module.preRun = Module.preRun || [];
Module.preRun.push(function () {
  FS.mkdir('/saves');
  FS.mount(IDBFS, {}, '/saves');
  addRunDependency('gbrt-saves');
  FS.syncfs(true, function (err) {
    if (err) console.error('[gbrt] loading saves from IndexedDB failed', err);
    removeRunDependency('gbrt-saves');
  });
});

// Called from platform_sdl.cpp after each committed save; coalesces overlapping syncs.
var gbrtSyncBusy = false, gbrtSyncAgain = false;
Module.gbrtSyncSaves = function () {
  if (gbrtSyncBusy) { gbrtSyncAgain = true; return; }
  gbrtSyncBusy = true;
  FS.syncfs(false, function (err) {
    gbrtSyncBusy = false;
    if (err) console.error('[gbrt] writing saves to IndexedDB failed', err);
    if (Module.onSavesSynced) Module.onSavesSynced(err);
    if (gbrtSyncAgain) { gbrtSyncAgain = false; Module.gbrtSyncSaves(); }
  });
};
