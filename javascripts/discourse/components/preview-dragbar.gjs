import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { throttle } from "@ember/runloop";
import { service } from "@ember/service";

const START_DRAG_EVENTS = ["touchstart", "mousedown"];
const DRAG_EVENTS = ["touchmove", "mousemove"];
const END_DRAG_EVENTS = ["touchend", "mouseup"];

const THROTTLE_RATE = 20;

/**
 * Get the y position of the mouse or touch event
 * @param {MouseEvent|TouchEvent} e
 * @returns {number}
 */
function mouseYPos(e) {
  return e.clientY || (e.touches && e.touches[0] && e.touches[0].clientY);
}

/**
 * Get the x position of the mouse or touch event
 * @param {MouseEvent|TouchEvent} e
 * @returns {number}
 */
function mouseXPos(e) {
  return e.clientX || (e.touches && e.touches[0] && e.touches[0].clientX);
}

export default class PreviewDragbar extends Component {
  @service composer;

  horizontalDragging = false;
  verticalDragging = false;
  origPreviewSize = 0;
  container = document.querySelector(".d-editor-container");

  constructor() {
    super(...arguments);
    const flex = localStorage.getItem("composerPreviewFlex");
    if (flex) {
      document.documentElement.style.setProperty(
        "--composer-preview-flex",
        "none"
      );
    }
    const width = localStorage.getItem("composerPreviewWidth");
    if (width) {
      document.documentElement.style.setProperty(
        "--composer-preview-width",
        width
      );
    }
    const height = localStorage.getItem("composerPreviewHeight");
    if (height) {
      document.documentElement.style.setProperty(
        "--composer-preview-height",
        height
      );
    }
  }

  /**
   * Dragging the preview resize bar
   * @param {MouseEvent} e
   */
  @action
  dragging(e) {
    if (this.horizontalDragging) {
      const currentMousePos = mouseXPos(e);
      // let the CSS handle the max min
      const offset =
        localStorage.getItem("composer-preview-location") === "left"
          ? currentMousePos - this.lastMousePos
          : this.lastMousePos - currentMousePos;
      const pointerRelativeXpos = this.origPreviewSize + offset;
      document.documentElement.style.setProperty(
        "--composer-preview-width",
        `${pointerRelativeXpos}px`
      );
      document.documentElement.style.setProperty(
        "--composer-preview-flex",
        "none"
      );
      // save the height/width for future sessions
      localStorage.setItem("composerPreviewWidth", `${pointerRelativeXpos}px`);
      localStorage.setItem("composerPreviewFlex", "none");
    }

    if (this.verticalDragging) {
      const currentMousePos = mouseYPos(e);
      // let the CSS handle the max min
      const offset =
        localStorage.getItem("composer-preview-location") === "top"
          ? currentMousePos - this.lastMousePos
          : this.lastMousePos - currentMousePos;
      const pointerRelativeXpos = this.origPreviewSize + offset;
      document.documentElement.style.setProperty(
        "--composer-preview-height",
        `${pointerRelativeXpos}px`
      );
      document.documentElement.style.setProperty(
        "--composer-preview-flex",
        "none"
      );
      localStorage.setItem("composerPreviewHeight", `${pointerRelativeXpos}px`);
      localStorage.setItem("composerPreviewFlex", "none");
    }
  }

  /**
   * Throttled version of dragging
   * @param {MouseEvent} e
   */
  @action
  throttledDragging(e) {
    e.preventDefault();
    throttle(this, this.dragging, e, THROTTLE_RATE);
  }

  /**
   * dragging
   * @param {MouseEvent} event
   */
  @action
  startDragHandler(event) {
    event.preventDefault();
    this.horizontalDragging = event.target.className.includes("horizontal");
    this.verticalDragging = event.target.className.includes("vertical");
    const preview = document.querySelector(".d-editor-preview-wrapper");

    if (!preview) {
      // this shouldn't be necessary, but in the off chance that preview isn't available...
      return;
    }

    if (this.horizontalDragging) {
      this.lastMousePos = mouseXPos(event);
      this.origPreviewSize = preview.offsetWidth;
    }
    if (this.verticalDragging) {
      this.lastMousePos = mouseYPos(event);
      this.origPreviewSize = preview.offsetHeight;
    }

    // applies event to document so that dragging can continue even when mouse leaves the element
    // prevents jumpy behaviour when moving mouse too fast
    DRAG_EVENTS.forEach((dragEvent) => {
      document.addEventListener(dragEvent, this.throttledDragging);
    });

    END_DRAG_EVENTS.forEach((endDragEvent) => {
      document.addEventListener(endDragEvent, this.endDragHandler);
    });
  }

  @action
  endDragHandler() {
    this.horizontalDragging = false;
    this.verticalDragging = false;

    DRAG_EVENTS.forEach((dragEvent) => {
      document.removeEventListener(dragEvent, this.throttledDragging);
    });

    END_DRAG_EVENTS.forEach((endDragEvent) => {
      document.removeEventListener(endDragEvent, this.endDragHandler);
    });
  }

  /**
   * Register event listeners for dragbar
   * @param {HTMLElement} element
   */
  @action
  registerListeners(element) {
    START_DRAG_EVENTS.forEach((startDragEvent) => {
      element.addEventListener(startDragEvent, this.startDragHandler, {
        passive: false,
      });
    });
  }

  /**
   * Unregister event listeners for dragbar
   * @param {HTMLElement} element
   */
  @action
  unregisterListeners(element) {
    START_DRAG_EVENTS.forEach((startDragEvent) => {
      element.removeEventListener(startDragEvent, this.startDragHandler);
    });
  }

  @action
  doubleClick() {
    if (
      document.documentElement.style.getPropertyValue(
        "--composer-preview-flex"
      ) === "none"
    ) {
      document.documentElement.style.setProperty("--composer-preview-flex", "");
      localStorage.removeItem("composerPreviewFlex");
    } else {
      document.documentElement.style.setProperty(
        "--composer-preview-flex",
        "none"
      );
      localStorage.setItem("composerPreviewFlex", "none");
    }
  }

  <template>
    {{#if this.composer.showPreview}}
      {{#if settings.allow_resizable_horizontal_previews}}
        <div
          class="preview-dragbar-horizontal"
          {{didInsert this.registerListeners}}
          {{willDestroy this.unregisterListeners}}
          {{on "dblclick" (fn this.doubleClick "horizontal")}}
        ></div>
      {{/if}}
      {{#if settings.allow_resizable_vertical_previews}}
        <div
          class="preview-dragbar-vertical"
          {{didInsert this.registerListeners}}
          {{willDestroy this.unregisterListeners}}
          {{on "dblclick" (fn this.doubleClick "vertical")}}
        ></div>
      {{/if}}
    {{/if}}
  </template>
}
