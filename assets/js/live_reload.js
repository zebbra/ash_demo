window.addEventListener("phx:live_reload:attached", ({ detail: reloader }) => {
  // enable server log streaming to client.
  // disable with reloader.disableServerLogs()
  reloader.enableServerLogs();

  // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
  //
  //   * click with "c" key pressed to open at caller location
  //   * click with "d" key pressed to open at function component definition location
  let keyDown;

  window.addEventListener("keydown", (e) => (keyDown = e.key));
  window.addEventListener("keyup", (_e) => (keyDown = null));

  window.addEventListener(
    "click",
    (e) => {
      if (keyDown === "c") {
        e.preventDefault();
        e.stopImmediatePropagation();

        reloader.openEditorAtCaller(e.target);
      } else if (keyDown === "d") {
        e.preventDefault();
        e.stopImmediatePropagation();

        reloader.openEditorAtDef(e.target);
      }
    },
    true,
  );

  window.liveReloader = reloader;
});
