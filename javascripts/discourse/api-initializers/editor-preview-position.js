import { apiInitializer } from "discourse/lib/api";
import PreviewPositionSelector from "../components/preview-position-selector";

export default apiInitializer("1.13.0", (api) => {
  api.renderInOutlet("before-composer-toggles", PreviewPositionSelector);
});
