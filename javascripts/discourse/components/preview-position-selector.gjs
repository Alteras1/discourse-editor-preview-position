import Component from "@glimmer/component";
import { hash } from "@ember/helper";
import { service } from "@ember/service";
import DropdownSelectBox from "discourse/select-kit/components/dropdown-select-box";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";

export default class PreviewPositionSelector extends Component {
  @service composer;
  @service previewPosition;
  @service site;

  get options() {
    const positions = ["right", "left"];
    if (settings.allow_top_bottom_previews) {
      positions.push("top", "bottom");
    }

    return positions.map((position) => ({
      id: position,
      label: i18n(themePrefix(`preview_location_${position}`)),
      value: position,
      icon: `editor-preview-${position}`,
    }));
  }

  get previewIcon() {
    return this.composer.showPreview
      ? "editor-preview-hide"
      : "editor-preview-show";
  }

  <template>
    {{#if this.site.desktopView}}
      {{#if settings.top_bar_preview_button}}
        <DButton
          class="btn-transparent btn-small top-bar-preview"
          @action={{this.composer.togglePreview}}
          @icon={{this.previewIcon}}
          @translatedTitle={{this.composer.toggleText}}
        />
      {{/if}}
      {{#if this.composer.showPreview}}
        <DropdownSelectBox
          class="preview-position-selector"
          @content={{this.options}}
          @nameProperty="label"
          @onChange={{this.previewPosition.apply}}
          @options={{hash
            autoFilterable=false
            customStyle=true
            filterable=false
            headerAriaLabel="preview_location"
            showCaret=false
            showFullTitle=true
            title=(themePrefix "preview_location")
          }}
          @value={{this.previewPosition.location}}
        />
      {{/if}}
    {{/if}}
  </template>
}
