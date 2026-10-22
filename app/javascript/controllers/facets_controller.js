import { Controller } from '@hotwired/stimulus';

// The criminality pages' facets fold away to give the chart and the tables the full width, and unfold back. The facets'
// own sections collapse too; their events bubble up here and are left alone.
export default class extends Controller {
  static targets = ['facets', 'results'];

  hide(event) {
    if (event.target === this.facetsTarget) this.resultsTarget.classList.add('col-lg-12');
  }

  show(event) {
    if (event.target === this.facetsTarget) this.resultsTarget.classList.remove('col-lg-12');
  }
}
