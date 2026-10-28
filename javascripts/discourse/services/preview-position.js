import { tracked } from "@glimmer/tracking";
import { registerDestructor } from "@ember/destroyable";
import Service, { service } from "@ember/service";

const POSITIONS = ["right", "left", "top", "bottom"];
const HORIZONTAL_POSITIONS = ["right", "left"];
const LOCATION_KEY = "composer-preview-location";

const FLEX_VAR = "--composer-preview-flex";

const SIZES = {
  horizontal: {
    cssVar: "--composer-preview-width",
    storageKey: "composerPreviewWidth",
  },
  vertical: {
    cssVar: "--composer-preview-height",
    storageKey: "composerPreviewHeight",
  },
};
const SIZE_VALUES = Object.values(SIZES);

export default class PreviewPosition extends Service {
  @service keyValueStore;

  @tracked location = "right";

  // arrow function so it can be passed as a bare callback (e.g. @onChange)
  apply = (location) => {
    const allowed =
      POSITIONS.includes(location) &&
      (settings.allow_top_bottom_previews ||
        HORIZONTAL_POSITIONS.includes(location));

    const next = allowed ? location : "right";

    document.body.classList.remove(`composer-preview-${this.location}`);
    this.location = next;
    document.body.classList.add(`composer-preview-${this.location}`);

    this.keyValueStore.set({ key: LOCATION_KEY, value: this.location });
    this.#syncFlex();
  };

  constructor(owner, args) {
    super(owner, args);

    // load sizes before apply so #syncFlex sees them on the single call inside apply
    for (const { cssVar, storageKey } of SIZE_VALUES) {
      const size = this.keyValueStore.get(storageKey);
      if (size) {
        document.documentElement.style.setProperty(cssVar, size);
      }
    }
    this.apply(this.keyValueStore.get(LOCATION_KEY) ?? "right");

    // remove the body class when the service is torn down (e.g. between tests)
    registerDestructor(this, () => {
      document.body.classList.remove(`composer-preview-${this.location}`);
    });
  }

  get axis() {
    return HORIZONTAL_POSITIONS.includes(this.location)
      ? "horizontal"
      : "vertical";
  }

  setSize(size) {
    document.documentElement.style.setProperty(SIZES[this.axis].cssVar, size);
    this.#syncFlex();
  }

  saveSize(size) {
    this.keyValueStore.set({ key: SIZES[this.axis].storageKey, value: size });
  }

  resetSize() {
    document.documentElement.style.removeProperty(SIZES[this.axis].cssVar);
    this.keyValueStore.remove(SIZES[this.axis].storageKey);
    this.#syncFlex();
  }

  // the legacy flex layout only honours the size once the preview stops flexing
  #syncFlex() {
    const style = document.documentElement.style;
    const hasSize = SIZE_VALUES.some((s) => style.getPropertyValue(s.cssVar));
    if (hasSize) {
      style.setProperty(FLEX_VAR, "none");
    } else {
      style.removeProperty(FLEX_VAR);
    }
  }
}
