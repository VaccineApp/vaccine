src = files([
	'App.vala',
	'Catalog.vala',
	'FourChan.vala',
	'Thread.vala',
	'PostReplies.vala',
	'ErrorDialog.vala',
	'media/MediaPreview.vala',
	'media/ImagePreview.vala',
	'media/VideoPreview.vala',
	'media/MediaStore.vala',
	'model/Board.vala',
	'model/Page.vala',
	'model/Post.vala',
	'util/PostTextBuffer.vala',
	'util/PostTransformer.vala',
	'util/Stripper.vala',
	'view/CatalogItem.vala',
	'view/CatalogWidget.vala',
	'view/CoverImage.vala',
	'view/MainWindow.vala',
	'view/MediaView.vala',
	'view/NotebookPage.vala',
	'view/PanelView.vala',
	'view/PostListRow.vala',
	'view/PreferencesView.vala',
	'view/ShortcutsWindow.vala',
	'view/ThreadPane.vala',
	'view/widgets/VideoPreviewWidget.vala',

	'config.vapi'
])

config = configure_file(input: 'config.h.in', output: 'config.h', configuration: conf)
config_inc = include_directories('.')
