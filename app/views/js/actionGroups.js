document.addEventListener('DOMContentLoaded', () => {
  const CELL_CLASSES = ['action-cell', 'action-cell-first', 'action-cell-middle', 'action-cell-last', 'action-cell-single'];

  function hasActionButton(cell) {
    if (!cell) return false;
    if (cell.querySelector('input:not([type="hidden"]), select, textarea')) return false;

    const buttons = cell.querySelectorAll('a.btn, button.btn, form .btn, .FormularioAjax .btn, .FormularioAjaxJs .btn');
    if (!buttons.length) return false;

    const text = (cell.textContent || '').replace(/\s+/g, ' ').trim();
    return text.length <= 24;
  }

  function markRow(row) {
    if (!row || !row.cells || !row.cells.length) return;

    Array.from(row.cells).forEach((cell) => cell.classList.remove(...CELL_CLASSES));

    let run = [];
    const flush = () => {
      if (!run.length) return;

      if (run.length === 1) {
        run[0].classList.add('action-cell', 'action-cell-single');
      } else {
        run.forEach((cell, index) => {
          cell.classList.add('action-cell');
          if (index === 0) {
            cell.classList.add('action-cell-first');
          } else if (index === run.length - 1) {
            cell.classList.add('action-cell-last');
          } else {
            cell.classList.add('action-cell-middle');
          }
        });
      }

      run = [];
    };

    Array.from(row.cells).forEach((cell) => {
      if (hasActionButton(cell)) {
        run.push(cell);
      } else {
        flush();
      }
    });

    flush();
  }

  function refreshActionGroups(scope = document) {
    scope.querySelectorAll('table tbody tr').forEach(markRow);
  }

  let rafId = 0;
  function queueRefresh() {
    if (rafId) return;
    rafId = window.requestAnimationFrame(() => {
      rafId = 0;
      refreshActionGroups(document);
    });
  }

  refreshActionGroups(document);

  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (mutation.type === 'childList' && (mutation.addedNodes.length || mutation.removedNodes.length)) {
        queueRefresh();
        return;
      }
    }
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
});
