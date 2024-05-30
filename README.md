# Editor Preview Position

Allows the user to reposition and resize the preview in the composer for Discourse.

For more information, please see: [Editor Preview Position - Discourse Meta](https://meta.discourse.org/t/editor-preview-position/309934)

![composer gif](.github/images/editor-preview-position.gif)
![fullscreen composer gif](.github/images/editor-preview-position-fullscreen.gif)

Also adds the option to style the composer in the same style as the fullscreen view.

![clean style composer](.github/images/editor-preview-position-clean-style.gif)

## Settings

### Top Bar Preview Button

Moves the preview button to the top bar. Default: `true`

<details>
<summary>Screenshots</summary>

![composer preview](.github/images/default-composer.png)
![composer no preview](.github/images/default-composer-preview-hidden.png)
![fullscreen composer preview](.github/images/fullscreen-composer.png)
![fullscreen composer no preview](.github/images/fullscreen-composer-preview-hidden.png)

</details>

### Allow Top Bottom Previews

Allows the preview to be position above/below the editor. Default: `true`

<details>
<summary>Screenshots</summary>

![composer top bottom](.github/images/composer-top-bottom.png)
![fullscreen composer top bottom](.github/images/fullscreen-composer-top-bottom.png)

</details>

### Allow Resizable Horizontal Previews

Allow the previews to be resizable along the horizontal axis. Default: `true`

### Allow Resizable Vertical Previews

Allow the previews to be resizable along the vertical axis. Default: `true`

### Clean Composer Style

Alters the composer style to more closely match the fullscreen composer style. Default: `false`

<details>
<summary>Screenshots</summary>

![clean style right](.github/images/clean-style-right.png)
![clean style left](.github/images/clean-style-left.png)
![clean style top](.github/images/clean-style-top.png)
![clean style bottom](.github/images/clean-style-bottom.png)

</details>

## Compatibility

Only works in Discourse v3.2.0 and above due to usage of `api.renderInOutlet()` function and new glimmer components.

## Local Development

For a guide to local theme, see [Discourse Theme CLI](https://meta.discourse.org/t/install-the-discourse-theme-cli-console-app-to-help-you-build-themes/82950) or the [Starter Guide](https://meta.discourse.org/t/get-started-with-theme-creator-and-the-theme-cli/108444).

```bash
discourse_theme watch ./
```
