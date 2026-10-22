import { Controller } from '@hotwired/stimulus';

// Filters a table's rows by what the visitor types, in the cells marked data-search-value, regardless of diacritics and
// case. It counts the rows left, says when none is, and offers to clear the query. Long tables wait for a pause in
// typing.
export default class extends Controller {
  static targets = ['input', 'reset', 'count', 'empty'];

  disconnect() {
    clearTimeout(this.timeout);
  }

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => this.filter(), this.rows.length > 500 ? 450 : 0);
  }

  reset(event) {
    event.preventDefault();

    this.inputTarget.value = '';
    this.filter();
    this.inputTarget.focus();
  }

  filter() {
    const query = fold(this.inputTarget.value.trim());

    this.rows.forEach((row) => {
      const values = Array.from(row.querySelectorAll('[data-search-value]'), (cell) => fold(cell.dataset.searchValue));

      row.hidden = query !== '' && values.length > 0 && !values.some((value) => value.includes(query));
    });

    const count = this.rows.filter((row) => !row.hidden).length;

    this.countTarget.textContent = count;
    this.emptyTarget.hidden = count > 0;
    this.resetTarget.hidden = query === '';
  }

  get rows() {
    return Array.from(this.element.querySelectorAll('tbody tr')).filter((row) => row !== this.emptyTarget);
  }
}

function fold(text) {
  return text
    .normalize('NFD')
    .replace(/\p{Mn}/gu, '')
    .toLowerCase();
}
