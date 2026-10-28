import { apiInitializer } from "discourse/lib/api";
import PreviewDragbar from "../components/preview-dragbar.gjs";
import PreviewPositionSelector from "../components/preview-position-selector.gjs";

export default apiInitializer((api) => {
  api.renderInOutlet("before-composer-toggles", PreviewPositionSelector);
  api.renderInOutlet("after-d-editor", PreviewDragbar);
});
