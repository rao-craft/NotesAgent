//  WHAT: Every word, symbol, size and timing the views show or keep, by key, with its default: what `strings`,
//        `symbols`, `sizes` and `motion` lines set. A template names each by key (`{{s:library.title}}`) and the
//        call's value, or the default, is written there as Swift.
//  PIN:  EVERY KEY HAS A NATURAL DEFAULT, so a call sets only what its app says differently; the tests hold every
//        key a template names to these tables, and every key here to a template.

import Foundation

enum WordTable {
    struct Entry: Sendable {
        let key: String
        let value: String
        let doc: String
        init(_ key: String, _ value: String, _ doc: String) { self.key = key; self.value = value; self.doc = doc }
    }

    /// The words, as plain text: `\n` in a value is a line break.
    static let strings: [Entry] = [
        Entry("library.title", "Notes", "the bar's title over the grid"),
        Entry("library.memoriesTitle", "Memories", "the bar's title while the grid shows only memories"),
        Entry("library.more", "More options", "the bar menu's label, read aloud"),
        Entry("library.about", "About", "the bar menu's item, which calls `about`"),
        Entry("library.filtered", "A category is selected", "the filter button, read aloud while a category filters the grid"),
        Entry("library.unfiltered", "No categories are selected", "the filter button, read aloud while nothing filters the grid"),
        Entry("library.memoriesShown", "Memories only shown.", "the memories button, read aloud while it is on"),
        Entry("library.memoriesHidden", "Other categories shown.", "the memories button, read aloud while it is off"),
        Entry("library.new", "New note", "the new-note button, read aloud"),
        Entry("library.emptyTitle", "This looks a little empty...", "the grid with no notes: its title"),
        Entry("library.emptyAction", "Create a note!", "the grid with no notes: the button that starts one"),
        Entry("library.filteredTitle", "No Notes", "a filter with no notes: its title"),
        Entry("library.filteredMessage", "Start writing and assign a category!", "a filter with no notes: the line under it"),
        Entry("card.untitled", "Untitled", "a card's title when the note has none"),
        Entry("card.noContent", "No content...", "a card's text when the note has none"),
        Entry("card.changeCategory", "Change category", "a card's menu item that files the note"),
        Entry("card.delete", "Delete", "a card's menu item that deletes the note"),
        Entry("sheet.dismiss", "Dismiss", "a category sheet's close button, read aloud"),
        Entry("picker.title", "Select a Category", "the category sheet's title"),
        Entry("picker.editingTitle", "Edit your Categories", "the category sheet's title while editing"),
        Entry("picker.edit", "Edit", "the category sheet's button that starts editing"),
        Entry("picker.done", "Done", "the category sheet's button that ends editing"),
        Entry("picker.all", "All notes", "the category sheet's floating button that clears the filter"),
        Entry("picker.add", "Create a Category", "the round button that adds a category while editing, read aloud"),
        Entry("picker.select", "Select Category", "a category's menu item that filters by it"),
        Entry("picker.unselect", "Unselect Category", "a category's menu item that clears its filter"),
        Entry("picker.editCategory", "Edit Category", "a category's menu item that opens its editor"),
        Entry("picker.fileTitle", "Change Note Category", "the sheet that files a note: its title"),
        Entry("picker.fileCreate", "Create and assign new category", "the filing sheet's floating button"),
        Entry("picker.createTitle", "Create a new category", "the alert that names a new category"),
        Entry("picker.namePlaceholder", "Enter your category name", "the alert's field"),
        Entry("picker.createSave", "Save and Assign", "the alert's button that makes the category and files the note"),
        Entry("picker.cancel", "Cancel", "the alert's cancel button"),
        Entry("picker.createMessage", "Your category will be created and assigned to your note.", "the alert's message"),
        Entry("category.newTitle", "New Category", "the category editor's title for a new one"),
        Entry("category.editTitle", "Edit Category", "the category editor's title"),
        Entry("category.namePlaceholder", "Name your category...", "the category editor's name field"),
        Entry("category.colorLabel", "Set the category color", "the colour well, read aloud"),
        Entry("category.cancel", "Cancel", "the category editor's cancel button"),
        Entry("category.ok", "Ok", "the button that drops the keyboard, read aloud"),
        Entry("category.delete", "Delete Category", "the category editor's delete button, read aloud"),
        Entry("category.save", "Save", "the category editor's save button"),
        Entry("category.deleteTitle", "Confirm Category Deletion", "the dialog before a category is deleted"),
        Entry("category.deleteMessage", "Are you sure you want to delete this category?\nAll notes in the \"{name}\" category will be moved to the {general} category.",
              "the dialog's message: {name} is the category's, {general} the general category's"),
        Entry("category.deleteConfirm", "Yes, delete this category", "the dialog's destructive button"),
        Entry("category.deleteCancel", "Cancel", "the dialog's cancel button"),
        Entry("category.unnamed", "Unnamed", "a category with no name"),
        Entry("editor.bodyPlaceholder", "What's on your mind?", "the empty text's placeholder"),
        Entry("editor.cancel", "Cancel", "a new note's button that discards it"),
        Entry("editor.save", "Save", "a new note's button that keeps it"),
        Entry("editor.more", "More options", "the editor menu's label, read aloud"),
        Entry("editor.delete", "Delete", "the editor menu's item that deletes the note"),
        Entry("editor.hideKeyboard", "Hide keyboard", "the buttons that drop the keyboard, read aloud"),
        Entry("editor.category", "Category: {name}.", "the category chip, read aloud; `{name}` is the category's"),
        Entry("format.title", "Format", "the Format sheet's title"),
        Entry("format.done", "Done", "the Format sheet's button that closes it"),
        Entry("format.style", "Style", "the Format sheet's section of styles"),
        Entry("format.bold", "Bold", "the bold style"),
        Entry("format.italic", "Italic", "the italic style"),
        Entry("format.underline", "Underlined", "the underline style"),
        Entry("format.strikethrough", "Strikethrough", "the strikethrough style"),
        Entry("format.fontSize", "Font Size", "the Format sheet's section of the size"),
        Entry("format.size", "{size} pt", "the size as the Format sheet shows it: {size} is the number"),
        Entry("format.alignment", "Alignment", "the section and pickers of alignment"),
        Entry("format.left", "Left", "left alignment, read aloud"),
        Entry("format.center", "Center", "centred alignment, read aloud"),
        Entry("format.right", "Right", "right alignment, read aloud"),
        Entry("format.justified", "Justified", "justified alignment, read aloud"),
        Entry("format.color", "Color", "the Format sheet's section of colours"),
        Entry("format.text", "Text", "the text colour's row"),
        Entry("format.textColor", "Text color", "the text colour well, read aloud"),
        Entry("format.highlight", "Highlight", "the highlight colour's row"),
        Entry("format.highlightColor", "Highlight color", "the highlight colour well, read aloud"),
        Entry("format.undo", "Undo", "the bar's undo button, read aloud"),
        Entry("format.redo", "Redo", "the bar's redo button, read aloud"),
        Entry("format.smaller", "Smaller", "the bar's smaller-size button, read aloud"),
        Entry("format.larger", "Larger", "the bar's larger-size button, read aloud"),
        Entry("toast.noteCreated", "Note created!", "the toast when a new note is saved"),
        Entry("toast.categoryCreated", "Category created!", "the toast when a category is made"),
        Entry("toast.categoryAssigned", "And assigned to your note", "the toast's second line when it is made from the filing sheet"),
    ]

    /// Words of which a view shows one: the values joined by ` | ` (one picked when the view appears).
    static let lists: [Entry] = [
        Entry("library.emptyMessages", "What's on your mind? | How's been your day? | How are you feeling right now? | It's OK. Write it down. | Make today a little bit better. | Let the words flow. | Capture the moment. | Start the symphony of thoughts.",
              "the grid with no notes: the line under its title, one picked"),
        Entry("editor.titlePlaceholder", "Title your note... | Title your imagination... | Title your inspiration...",
              "the empty title's placeholder, one picked"),
    ]

    /// SF Symbols by key.
    static let symbols: [Entry] = [
        Entry("library.more", "ellipsis.circle", "the bar menu"),
        Entry("library.about", "book.pages", "the bar menu's about item"),
        Entry("library.filter", "line.3.horizontal.decrease.circle", "the filter, nothing selected"),
        Entry("library.filterOn", "line.3.horizontal.decrease.circle.fill", "the filter, a category selected"),
        Entry("library.memories", "brain", "the memories button, off"),
        Entry("library.memoriesOn", "brain.fill", "the memories button, on"),
        Entry("library.new", "plus", "the new-note button"),
        Entry("library.empty", "note.text", "the grid with no notes"),
        Entry("library.filteredEmpty", "pencil.and.scribble", "a filter with no notes"),
        Entry("card.changeCategory", "arrow.forward.folder", "a card's filing item"),
        Entry("card.delete", "trash.fill", "a card's delete item"),
        Entry("card.cloud", "point.3.filled.connected.trianglepath.dotted", "the badge on a memory's card and on a note that lives only on the server"),
        Entry("sheet.dismiss", "xmark", "a category sheet's close button"),
        Entry("picker.off", "circle", "a category that is not selected"),
        Entry("picker.on", "circle.fill", "the selected category"),
        Entry("picker.edit", "chevron.right", "a category while editing"),
        Entry("picker.add", "plus", "the round button that adds a category"),
        Entry("picker.select", "checkmark.circle", "a category's menu item that filters by it"),
        Entry("picker.unselect", "xmark.circle", "a category's menu item that clears its filter"),
        Entry("picker.editCategory", "pencil", "a category's menu item that opens its editor"),
        Entry("category.ok", "checkmark", "the category editor's button that drops the keyboard"),
        Entry("category.delete", "trash", "the category editor's delete button and dialog"),
        Entry("editor.more", "ellipsis.circle", "the editor menu"),
        Entry("editor.delete", "trash.fill", "the editor menu's delete item"),
        Entry("editor.hideKeyboard", "chevron.down", "the bar's button that drops the keyboard"),
        Entry("format.undo", "arrow.uturn.backward", "the formatting bar's undo"),
        Entry("format.redo", "arrow.uturn.forward", "the formatting bar's redo"),
        Entry("format.open", "textformat", "the formatting bar's button that opens Format"),
        Entry("format.smaller", "minus", "a size smaller"),
        Entry("format.larger", "plus", "a size larger"),
        Entry("format.keyboard", "keyboard.chevron.compact.down", "the formatting bar's button that drops the keyboard"),
        Entry("format.bold", "bold", "the bold style"),
        Entry("format.italic", "italic", "the italic style"),
        Entry("format.underline", "underline", "the underline style"),
        Entry("format.strikethrough", "strikethrough", "the strikethrough style"),
        Entry("format.left", "text.alignleft", "left alignment"),
        Entry("format.center", "text.aligncenter", "centred alignment"),
        Entry("format.right", "text.alignright", "right alignment"),
        Entry("format.justified", "text.justify", "justified alignment"),
    ]

    /// Sizes in points, counts and fractions by key.
    static let sizes: [Entry] = [
        Entry("grid.minimum", "160", "a grid column's least width"),
        Entry("grid.inset", "16", "the grid's inset from the sides"),
        Entry("grid.top", "8", "the grid's inset from the bar"),
        Entry("card.inset", "4", "each card's inset from its column's sides"),
        Entry("card.below", "8", "the space under each card"),
        Entry("card.padding", "16", "a card's padding"),
        Entry("card.radius", "16", "a card's corner radius"),
        Entry("card.border", "1", "a card's outline"),
        Entry("card.lines", "3", "the lines of text a card shows (whole)"),
        Entry("card.dot", "8", "the category dot on a card"),
        Entry("card.cloudSymbol", "11", "the symbol in a card's badge"),
        Entry("card.cloudPadding", "6", "the space around the symbol in a card's badge"),
        Entry("empty.symbol", "50", "an empty state's symbol"),
        Entry("empty.inset", "42", "an empty state's line, inset from the sides"),
        Entry("empty.below", "80", "the space under the empty grid's state"),
        Entry("filtered.below", "60", "the space under an empty filter's state"),
        Entry("picker.minimum", "160", "a category sheet column's least width"),
        Entry("picker.radius", "24", "the corner radius of a category's button, the floating button and the name field"),
        Entry("picker.stroke", "4", "the outline of a category's button, the floating buttons and the name field"),
        Entry("picker.detent", "0.6", "the category sheets' height, a fraction of the screen"),
        Entry("category.detent", "0.6", "the category editor's height, a fraction of the screen"),
        Entry("editor.titleSpacing", "8", "the space above and below the title"),
        Entry("editor.titleInset", "16", "the title's inset from the leading edge"),
        Entry("editor.textInset", "12", "the text's inset on every side"),
        Entry("editor.chipInset", "8", "the category chip's inset at its sides"),
        Entry("editor.chipDot", "10", "the category chip's dot"),
        Entry("bar.height", "50", "the formatting bar's height"),
        Entry("bar.radius", "24", "the formatting bar's corner radius"),
        Entry("bar.inset", "12", "the formatting bar's inset from the sides and the keyboard"),
        Entry("bar.spacing", "15", "the space between the formatting bar's controls"),
        Entry("bar.divider", "22", "the formatting bar's divider"),
        Entry("format.minimum", "6", "the least font size"),
        Entry("format.maximum", "96", "the largest font size"),
        Entry("format.step", "1", "a font size step"),
    ]

    /// Sizes that are counts.
    static let wholeSizes: Set<String> = ["card.lines"]
    /// Sizes that are fractions of the screen, above 0 and at most 1.
    static let fractionSizes: Set<String> = ["picker.detent", "category.detent"]

    /// Animations and delays by key.
    static let motion: [Entry] = [
        Entry("library.filter", ".bouncy", "a category chosen, or the filter cleared"),
        Entry("library.delete", ".bouncy", "a note or a category leaving"),
        Entry("picker.edit", ".bouncy", "the category sheet going into editing and out"),
        Entry("editor.deleteDelay", "0.6", "seconds from the editor closing to its deleted note leaving the grid"),
        Entry("category.deleteDelay", "0.4", "seconds from the category editor closing to its deleted category leaving"),
    ]

    /// Motion keys that are seconds, not animations.
    static let seconds: Set<String> = ["editor.deleteDelay", "category.deleteDelay"]

    static func entry(_ key: String, in table: [Entry]) -> Entry? { table.first { $0.key == key } }
}
