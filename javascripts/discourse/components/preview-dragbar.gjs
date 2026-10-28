import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DResizeSeparator from "discourse/ui-kit/d-resize-separator";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import { i18n } from "discourse-i18n";

const MIN_RATIO = 0.15;
const MAX_RATIO = 0.85;
const MIN_EDITOR_HEIGHT = 64;

// the edge opposite the one that moves, which is the preview's far edge
const SIDES = { right: "end", left: "start", top: "start", bottom: "end" };

export default class PreviewDragbar extends Component {
  @service composer;
  @service previewPosition;
  @service site;

  measurePreview = (separator) => {
    this.container = separator.closest(".d-editor-container");
    this.preview = this.container?.querySelector(
      ":scope > .d-editor-preview-wrapper"
    );
    return this.preview;
  };

  // the grid track includes the preview's padding and border, which the
  // separator's own measurement leaves out
  size = () => {
    const { width, height } = this.preview.getBoundingClientRect();
    return this.horizontal ? width : height;
  };

  min = () => this.availableSize * MIN_RATIO;

  max = () =>
    this.horizontal
      ? this.availableSize * MAX_RATIO
      : this.availableSize - MIN_EDITOR_HEIGHT;

  get axis() {
    return this.previewPosition.axis;
  }

  get horizontal() {
    return this.axis === "horizontal";
  }

  get side() {
    return SIDES[this.previewPosition.location];
  }

  get resizable() {
    return settings[`allow_resizable_${this.axis}_previews`];
  }

  get availableSize() {
    const { clientWidth, clientHeight } = this.container;
    if (this.horizontal) {
      return clientWidth;
    }

    // the redesign puts the fields row in the container, the legacy composer
    // keeps it in the editor column
    const fields = this.container.querySelector(":scope > .composer-fields");
    return clientHeight - (fields?.offsetHeight ?? 0);
  }

  @action
  resize(size) {
    this.previewPosition.setSize(`${size}px`);
  }

  @action
  commit(size) {
    this.previewPosition.saveSize(`${size}px`);
  }

  @action
  reset() {
    this.previewPosition.resetSize();
  }

  <template>
    {{#if this.site.desktopView}}
      {{#if this.composer.showPreview}}
        {{#if this.resizable}}
          <DResizeSeparator
            class={{dConcatClass
              "preview-dragbar"
              (if this.horizontal "--horizontal" "--vertical")
            }}
            @axis={{this.axis}}
            @label={{i18n (themePrefix "preview_resize")}}
            @max={{this.max}}
            @measure={{this.measurePreview}}
            @min={{this.min}}
            @onResize={{this.resize}}
            @onResizeEnd={{this.commit}}
            @side={{this.side}}
            @value={{this.size}}
            {{on "dblclick" this.reset}}
          />
        {{/if}}
      {{/if}}
    {{/if}}
  </template>
}
