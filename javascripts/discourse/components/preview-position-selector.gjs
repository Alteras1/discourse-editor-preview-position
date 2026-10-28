import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DropdownSelectBox from "discourse/select-kit/components/dropdown-select-box";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";

export default class PreviewPositionSelector extends Component {
  @service composer;
  @service site;

  @tracked _previewLocation = "right";

  constructor() {
    super(...arguments);
    if (document.body.classList.contains("composer-preview-right")) {
      this._previewLocation = "right";
    } else if (document.body.classList.contains("composer-preview-left")) {
      this._previewLocation = "left";
    } else if (document.body.classList.contains("composer-preview-top")) {
      this._previewLocation = "top";
    } else if (document.body.classList.contains("composer-preview-bottom")) {
      this._previewLocation = "bottom";
    } else {
      this.setPreviewLocation(
        localStorage.getItem("composer-preview-location") || "right"
      );
    }
  }

  get previewLocation() {
    return this._previewLocation || "right";
  }

  get options() {
    let options = [
      {
        id: "right",
        label: i18n(themePrefix("preview_location_right")),
        value: "right",
        icon: "editor-preview-right",
      },
      {
        id: "left",
        label: i18n(themePrefix("preview_location_left")),
        value: "left",
        icon: "editor-preview-left",
      },
    ];
    if (settings.allow_top_bottom_previews) {
      options.push({
        id: "top",
        label: i18n(themePrefix("preview_location_top")),
        value: "top",
        icon: "editor-preview-top",
      });
      options.push({
        id: "bottom",
        label: i18n(themePrefix("preview_location_bottom")),
        value: "bottom",
        icon: "editor-preview-bottom",
      });
    }
    return options;
  }

  get showHidePreviewIcon() {
    return this.composer.showPreview ? "eye" : "eye-slash";
  }

  @action
  setPreviewLocation(location) {
    document.body.classList.remove(
      "composer-preview-right",
      "composer-preview-left",
      "composer-preview-top",
      "composer-preview-bottom"
    );
    switch (location) {
      case "top":
        document.body.classList.add("composer-preview-top");
        break;
      case "bottom":
        document.body.classList.add("composer-preview-bottom");
        break;
      case "left":
        document.body.classList.add("composer-preview-left");
        break;
      case "right":
      default:
        document.body.classList.add("composer-preview-right");
        break;
    }
    localStorage.setItem("composer-preview-location", location);
    this._previewLocation = location;
  }

  <template>
    {{#if this.site.desktopView}}
      {{#if settings.top_bar_preview_button}}
        {{#if this.composer.showPreview}}
          <DButton
            class="btn-flat btn-mini-toggle top-bar-preview"
            @action={{this.composer.togglePreview}}
            @icon="editor-preview-hide"
            @translatedTitle={{this.composer.toggleText}}
          />
        {{else}}
          <DButton
            class="btn-flat btn-mini-toggle top-bar-preview"
            @action={{this.composer.togglePreview}}
            @icon="editor-preview-show"
            @translatedTitle={{this.composer.toggleText}}
          />
        {{/if}}
      {{/if}}
      {{#if this.composer.showPreview}}
        <DropdownSelectBox
          class="preview-position-selector"
          @content={{this.options}}
          @nameProperty="label"
          @onChange={{this.setPreviewLocation}}
          @options={{hash
            showCaret=false
            showFullTitle=true
            headerAriaLabel="preview_location"
            title=(themePrefix "preview_location")
            customStyle=true
            fitlerable=false
            autoFilterable=false
          }}
          @value={{this.previewLocation}}
        />
      {{/if}}
    {{/if}}
  </template>
}
