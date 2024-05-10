import { apiInitializer } from "discourse/lib/api";
import PreviewDragbar from "../components/preview-dragbar";
import PreviewPositionSelector from "../components/preview-position-selector";

export default apiInitializer("1.13.0", (api) => {
  api.renderInOutlet("before-composer-toggles", PreviewPositionSelector);
  api.renderInOutlet("after-d-editor", PreviewDragbar);
});
