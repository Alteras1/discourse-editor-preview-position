# frozen_string_literal: true

RSpec.describe "Editor preview position", type: :system do
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }

  let(:composer) { PageObjects::Components::Composer.new }

  before do
    upload_theme_or_component
    SiteSetting.enable_composer_redesign = true
    sign_in(user)
    # clear any persisted size/position from previous runs to ensure a clean state
    page.execute_script(<<~JS)
      ["composerPreviewWidth", "composerPreviewHeight", "composer-preview-location"]
        .forEach(k => localStorage.removeItem(k));
    JS
  end

  def open_composer
    visit("/new-topic")
    expect(composer).to be_opened
  end

  def choose_position(position)
    find(".preview-position-selector summary").click
    find(".preview-position-selector [data-value='#{position}']").click
  end

  # Returns "left", "right", "top", or "bottom" based on where the preview
  # wrapper sits relative to the editor column in the viewport.
  def preview_visual_position
    page.evaluate_script(<<~JS)
      (function() {
        const preview = document.querySelector('.d-editor-preview-wrapper').getBoundingClientRect();
        const editor  = document.querySelector('.d-editor-textarea-column').getBoundingClientRect();
        const px = Math.round(preview.x), py = Math.round(preview.y);
        const ex = Math.round(editor.x),  ey = Math.round(editor.y);
        if (px < ex) return "left";
        if (px > ex) return "right";
        if (py < ey) return "top";
        if (py > ey) return "bottom";
        return "unknown";
      })()
    JS
  end

  # --------------------------------------------------------------------------
  # Position selector
  # --------------------------------------------------------------------------

  it "defaults to preview on the right" do
    open_composer
    expect(page).to have_css("body.composer-preview-right")
    expect(preview_visual_position).to eq("right")
  end

  %w[left top bottom].each do |position|
    it "moves the preview to the #{position}" do
      open_composer
      choose_position(position)
      expect(page).to have_css("body.composer-preview-#{position}")
      expect(preview_visual_position).to eq(position)
    end
  end

  it "persists the chosen position across page loads" do
    open_composer
    choose_position("left")
    expect(page).to have_css("body.composer-preview-left")

    visit("/new-topic")
    expect(composer).to be_opened
    expect(page).to have_css("body.composer-preview-left")
  end

  it "only shows the position selector while the preview is visible" do
    open_composer
    expect(page).to have_css(".preview-position-selector")

    find(".toggle-preview").click
    expect(page).to have_no_css(".preview-position-selector")

    find(".toggle-preview").click
    expect(page).to have_css(".preview-position-selector")
  end

  # --------------------------------------------------------------------------
  # Grid layout (redesign-specific)
  # --------------------------------------------------------------------------

  it "uses a grid layout with fields as a direct container child" do
    open_composer
    expect(page).to have_css(".d-editor-container > .composer-fields")
  end

  # --------------------------------------------------------------------------
  # Resize handle
  # --------------------------------------------------------------------------

  it "shows a horizontal drag handle in left/right positions" do
    open_composer
    expect(page).to have_css(".preview-dragbar.--horizontal")
  end

  def element_rect(selector)
    page.evaluate_script(<<~JS)
      (function() {
        const r = document.querySelector('#{selector}').getBoundingClientRect();
        return { width: Math.round(r.width), height: Math.round(r.height),
                 left: r.left, right: r.right };
      })()
    JS
  end

  it "visually grows the preview when dragging the handle" do
    open_composer
    width_before = element_rect(".d-editor-preview-wrapper")["width"]

    drag_with_pointer(from: ".preview-dragbar.--horizontal", by: { x: -100 })

    expect(element_rect(".d-editor-preview-wrapper")["width"]).to be_within(5).of(width_before + 100)
  end

  it "clamps the preview at 85% of the container and does not overlap the editor" do
    open_composer
    container = element_rect(".d-editor-container")

    drag_with_pointer(from: ".preview-dragbar.--horizontal", by: { x: -9999 })

    # single snapshot so all coordinates are measured in the same JS frame
    rects =
      page.evaluate_script(<<~JS)
        (function() {
          const p = document.querySelector('.d-editor-preview-wrapper').getBoundingClientRect();
          const e = document.querySelector('.d-editor-textarea-column').getBoundingClientRect();
          return { preview_width: Math.round(p.width), preview_left: p.left,
                   preview_right: p.right, editor_right: e.right };
        })()
      JS

    expect(rects["preview_width"]).to be <= (container["width"] * 0.85) + 2
    expect(rects["preview_left"]).to be >= rects["editor_right"] # no overlap
    expect(rects["preview_right"]).to be <= container["right"] + 2 # stays within container
  end

  it "clamps the preview at 15% of the container when shrinking" do
    open_composer
    container_width = element_rect(".d-editor-container")["width"]

    drag_with_pointer(from: ".preview-dragbar.--horizontal", by: { x: 9999 })

    expect(element_rect(".d-editor-preview-wrapper")["width"]).to be >= (container_width * 0.15) - 2
  end

  it "resets the preview size on double-click" do
    open_composer
    drag_with_pointer(from: ".preview-dragbar.--horizontal", by: { x: -100 })
    expect(page).to have_css("html[style*='--composer-preview-width']", visible: :all)

    find(".preview-dragbar.--horizontal").double_click

    expect(page).to have_no_css("html[style*='--composer-preview-width']", visible: :all)
  end

  it "visually grows the preview height when dragging in top position" do
    open_composer
    choose_position("top")

    expect(page).to have_css(".preview-dragbar.--vertical")
    height_before = element_rect(".d-editor-preview-wrapper")["height"]

    # the default composer height gives little vertical room — just assert the
    # size grew in the right direction rather than checking an exact delta
    drag_with_pointer(from: ".preview-dragbar.--vertical", by: { y: 20 })

    expect(element_rect(".d-editor-preview-wrapper")["height"]).to be > height_before
  end

  # --------------------------------------------------------------------------
  # Top-bar preview button
  # --------------------------------------------------------------------------

  it "hides the theme preview button and defers to core's toggle in the redesign" do
    open_composer

    # core's native toggle is always present in the redesign
    expect(page).to have_css(".toggle-preview")

    # the :has(~ .toggle-preview) CSS rule hides the theme's button since core's
    # toggle is always a sibling; verify it is not visible
    expect(page).to have_no_css(".top-bar-preview")
  end
end
