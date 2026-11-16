# craft-agent/1 · notes

Writes a notes library (a grid of note cards with a bar of menu, filter, memories and new note, empty states, and sheets that pick, add, edit and delete categories) and a rich-text note editor (title, attributed text, formatting bar, Format sheet) as plain SwiftUI, made to show the app's own note type from one mapping line.

notes' copy of Craft's agent standard (`craft-agent/1`, Craft's `Schema/Agent.md`), with the reference for every
field, line, key and launch state below it. **Changes** is notes' own log.

| File | What it holds |
| --- | --- |
| [`notes.input.schema.json`](notes.input.schema.json) | What it takes, as JSON Schema |
| [`notes.answer.schema.json`](notes.answer.schema.json) | What it answers: `granite-answer/1` with its own kinds |
| [`examples/seer.json`](examples/seer.json) | The call that writes Seer's Library and note editor |
| [`examples/seer.answer.json`](examples/seer.answer.json) | What that call answers, its paths relative to the project |
| [`examples/journal.json`](examples/journal.json) | A call for another app: a journal with its own entry and mood types |

## What it takes

| Field | Required | What it is |
| --- | --- | --- |
| `into` | no | the folder for the views, relative to the project; Components/Notes when left out |
| `prefix` | no | a prefix for the kit's types when the app already has those names: `Kit` writes KitNotesLibrary |
| `mappings` | no | one line a role (note, category): `note: Note title=title body=body category=category date=createdAt new=Note(id: UUID().uuidString, title: "", body: "", category: "General", createdAt: Date())`; a bare path is read off the value and written back, anything else is Swift that may name `value` |
| `imports` | no | modules the conformances import, such as the package a mapped type is declared in |
| `look` | no | `role = Swift`, the app's names for the look: accent, card, cardShadow, buttonShadow, panel, titleColor, noteColor (colours); title, note, note2, cardTitle, cardDate, cardText, cardCategory, editorTitle (fonts); a role left out keeps the original's value |
| `strings` | no | `key = text`, any word the views show (`library.title = Library`); `\|` between the items of a list key (`editor.titlePlaceholder`); every key has a default |
| `symbols` | no | `key = name`, any SF Symbol the views draw (`library.new = plus`); every key has a default |
| `sizes` | no | `key = number`, any size in points, count or fraction (`grid.minimum = 160`, `picker.detent = 0.6`); every key has a default |
| `motion` | no | `key = animation` (`library.filter = .bouncy`) or `key = seconds` (`editor.deleteDelay = 0.6`); every key has a default |
| `categories` | no | the categories the views start with: `general = General brown` (where new notes go), `memory = Memory green` (shown only under the memories button; none when left out), then one line a listed one, `Space brown` or `"Machine Learning" brown`, and `color = gray` for a new one |
| `launch` | no | `destination = state` for a launch with `-destination <name>`: grid, memories, categories, new (a new note's editor; with its title and text in quotes it opens written, the title focused: `note = new "Launch windows" "Mars and Earth line up…"`), or editor and a note's id or title, pushed (`note = editor space-001`) |

`directory` is filled by Craft with the project folder. The person's request and the host's model are offered
beside the call, never in it.

## What it makes

| Kind | What | Into | Never |
| --- | --- | --- | --- |
| `view` | a notes library and its rich-text editor as reusable SwiftUI views (NotesLibrary, the grid of note cards with its bar, empty states and category sheets, which pushes NoteEditor with its formatting bar and Format sheet); a page shows them with NotesLibrary(notes:…) | `Components/Notes/*` | routes; never a page, a service, a client or a model type |
| `conformance` | the app's own note and category types made the views' types: one extension a mapping line | `Components/Notes/Conformances/*` | a change to the app's types themselves |

## What it answers

A `granite-answer/1` answer (Granite's `Schema/GraniteAgent.md` §4.2): `paths`, `made` against `expected` by kind and
name, `problems` for what it could only do in part, and its own keys beside them:

- `views`: the views written, the root first (`NotesLibrary`);
- `conformances`: one line a mapping (`Note: note`);
- `roots`: the root's initializer as one line, with the app's note type in it, so the host can write the page body;
- `notes`: one sentence each for what the call left out or the app still has to do.

## How it refuses

With an `AgentRefusal` of kind `call`, every reason at once, each naming the field, the line and what it takes:

> mappings: note title=headline: \`Note\` has no \`headline\`: its fields are id, title, body, category, createdAt

Nothing is written until every problem is fixed and every file parses.

## The root and the page body

One root view sits in the app's navigation stack, whose bar it fills: the library, which pushes a note's editor from
its card and shows a new note's editor in a sheet.

```swift
NotesLibrary(notes: [Note], categories: [any NoteCategoryRepresentable] = [],
             refresh: (() async throws -> Void)? = nil,
             save: ((Note) async throws -> Void)? = nil,
             delete: ((Note) async throws -> Void)? = nil,
             about: (() -> Void)? = nil,
             toast: ((String) -> Void)? = nil,
             saveCategory: ((NotesCategory) async throws -> Void)? = nil,
             deleteCategory: ((NotesCategory) async throws -> Void)? = nil)
```

Every closure is main-actor isolated. A closure left out removes its control: no `save`, no plus, no "Create a
note!" and no filing; no `delete`, no "Delete"; no `about`, no more menu. A page that keeps its notes in a library
service writes:

```swift
NotesLibrary(notes: library.state.notes, refresh: { try await library.load() }, save: { try await library.save(note: $0) }, delete: { try await library.delete(note: $0) }, about: { layout.present(.about) }, toast: { modals.toast($0, style: .success) })
```

`save` keeps a new note, a note edited (as its editor closes, dated now when its words changed) and a note filed in
another category; the app puts the saved note first in its list. Categories made, renamed or deleted in the sheets
live in the view; `saveCategory` and `deleteCategory` keep them when the app has somewhere to.

## Mapping lines

```
note: Note title=title body=body category=category date=createdAt new=Note(id: UUID().uuidString, title: "", body: "", category: "General", createdAt: Date())
category: Folder id=slug name=title color=tint
```

A role, a colon, the type (`SeerKit.Note` names its module), then one `word=right side` a thing the views show, with
spaces or commas between them. A right side that is a bare path (`createdAt`, `meta?.title`) is read off the value
and written back when the editor changes it; anything else is Swift that may name `value` and is only read. A path
is checked against the app's own types when they are in the project: a field it lacks is refused with the fields it
has, `created_at` is written `createdAt`, a field of a type the word cannot show is refused, and a `let` field or a
path through an optional is read and never written, with a note. One line a role.

| Role | Word | Also read as | Becomes | Takes | Written back |
| --- | --- | --- | --- | --- | --- |
| `note` (or `entry`, `page`) | `title` | name, heading | `noteTitle: String` | String, Substring, UUID, Int | yes |
| | `body` | text, content | `noteBody: AttributedString` | AttributedString, String | yes |
| | `category` | folder, tag | `noteCategory: String`, the category's id or name; empty for the general one | String, Substring, UUID, Int | yes |
| | `date` | created, createdAt, updated, modified | `noteDate: Date`; the grid shows the newest first | Date, ISO String, seconds as Double or Int | yes |
| | `new` | make, empty | `static var notesNew: Self?`: Swift that makes an empty note; without it nothing makes a note | Swift | — |
| | `id` | | `id`, when the type has no `id` of its own | String, Substring, UUID, Int | — |
| `category` (or `folder`, `group`) | `name` | title | `noteCategoryName: String` | String, Substring, UUID, Int | — |
| | `color` | colour, tint | `noteCategoryColor: Color` | Color, or a String naming one (`brown`, `#AE9060`) | — |
| | `id` | | `noteCategoryID: String`, what a note's category names it by; its name when left out | String, Substring, UUID, Int | — |

With no note line the views show the kit's own `NotesEntry`. A mapped category type is passed to the root as
`categories:`, listed after the general one in place of the call's.

## Look

`look` lines map a role to the app's own Swift (`accent = Color.accent`, `title = Font.brandTitle`), written into
`NotesLook`, the one enum the views read. A role left out keeps the value the notes screens are drawn in, written
with system names, so the views build in any app. The card's fill and shadows and the panel are colours for light
and dark.

| Role | Kind | When unmapped | What it is |
| --- | --- | --- | --- |
| `accent` | Color | `Color.accentColor` | the tint: the bar's glyphs, the empty grid's action, a new category's plus, a style that is on |
| `card` | Color | `NotesPlatform.dynamic(light: .white, dark: .white.opacity(0.1))` | a card's fill, and where a category's gradient starts |
| `cardShadow` | Color | `NotesPlatform.dynamic(light: Color(red: 0.557, green: 0.557, blue: 0.557).opacity(0.14), dark: .clear)` | a card's shadow |
| `buttonShadow` | Color | `NotesPlatform.dynamic(light: Color(red: 0.557, green: 0.557, blue: 0.557).opacity(0.4), dark: .clear)` | the shadow under a category's button and the name field |
| `panel` | Color | `NotesPlatform.dynamic(light: .white, dark: Color(white: 0.1))` | where the category editor's background starts, above its colour |
| `titleColor` | Color | `Color.primary.opacity(0.75)` | the colour of `title` text |
| `noteColor` | Color | `Color.primary.opacity(0.6)` | the colour of `note` and `note2` text |
| `title` | Font | `Font.system(size: 24, weight: .regular, design: .serif)` | titles in the bar, and an empty state's title (drawn bold) |
| `note` | Font | `Font.system(size: 18, weight: .light, design: .serif)` | an empty filter's line (drawn italic) |
| `note2` | Font | `Font.system(size: 16, weight: .light, design: .serif)` | the empty grid's line (drawn italic) and its action |
| `cardTitle` | Font | `Font.system(size: 16, weight: .medium, design: .serif)` | a card's title |
| `cardDate` | Font | `Font.system(size: 14, weight: .regular, design: .serif)` | a card's date |
| `cardText` | Font | `Font.system(size: 12, weight: .regular, design: .serif)` | a card's lines of text |
| `cardCategory` | Font | `Font.system(size: 12, weight: .regular, design: .serif)` | a card's category name |
| `editorTitle` | Font | `Font.title` | the editor's title (drawn bold) |

## Categories

```
general = General brown          the one new notes go in and a deleted category's notes move to
memory = Memory green            notes shown only under the memories button, on cards with no title
Space brown                      a listed category: its name, then its colour
"Machine Learning" brown         a name of several words, quoted or not
color = gray                     a new category's colour, and that of one a note names that no line lists
```

A colour is a SwiftUI colour's name (red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown,
gray, black, white), `accent`, or `#RRGGBB`; a line with none takes `color`'s. They are written into
`NotesCategories`. A note names its category by id or name, in any case; one no line lists is shown with its own
name in the `color` colour. With no `memory` line there is no memories button.

## Launch

`launch` lines map a destination to the state the views open in when the app is launched with
`-destination <name>` (the `destination` default), written into `NotesLaunch`. The app's navigation opens the page;
the views open their own sheet or push once, unanimated, as if the person had gone there; a note's editor opens as
soon as its note has arrived.

| State | What opens |
| --- | --- |
| `grid` | the grid as it is |
| `memories` | the grid of memories |
| `categories` | the category sheet over the grid |
| `new` | a new note's editor in its sheet, empty, its title focused |
| `new "<title>" "<text>"` | a new note's editor in its sheet with that title and text already written, in the general category, its title focused at its end; the text alone may be left out |
| `editor` | a note's editor pushed, nothing focused: `editor space-001`, the note whose id, else whose title, it names |

In a written note's quotes, as in any quoted value, `\n` is a line break, `\"` a quote and `\\` a backslash:
`note = new "Launch windows" "Mars and Earth line up…\n\nPerseverance left in July 2020…"` writes two paragraphs.
The note is not saved until the person keeps it, as with any new note.

## Words, symbols, sizes and motion

`key = value` lines. A value may be quoted; in it `\n` is a line break, `\"` a quote and `\\` a backslash. A list
key takes its items between `|`, and the views pick one as they appear. A symbol is an SF Symbol's name. A size is
a number of points, unless the table says it is a count or a fraction of the screen. Motion is one of SwiftUI's
animations (`.bouncy`, `.smooth`, `.snappy`, `.easeInOut(duration: 0.3)`, `.spring(response: 0.4,
dampingFraction: 0.8)`, with `.delay(…)` or `.speed(…)`) or, for a delay, seconds. In a string, `{name}`, `{size}`
and `{general}` are filled in where the table says.

### Strings

| Key | Default | What it is |
| --- | --- | --- |
| `library.title` | `Notes` | the bar's title over the grid |
| `library.memoriesTitle` | `Memories` | the bar's title while the grid shows only memories |
| `library.more` | `More options` | the bar menu's label, read aloud |
| `library.about` | `About` | the bar menu's item, which calls `about` |
| `library.filtered` | `A category is selected` | the filter button, read aloud while a category filters the grid |
| `library.unfiltered` | `No categories are selected` | the filter button, read aloud while nothing filters the grid |
| `library.memoriesShown` | `Memories only shown.` | the memories button, read aloud while it is on |
| `library.memoriesHidden` | `Other categories shown.` | the memories button, read aloud while it is off |
| `library.new` | `New note` | the new-note button, read aloud |
| `library.emptyTitle` | `This looks a little empty...` | the grid with no notes: its title |
| `library.emptyAction` | `Create a note!` | the grid with no notes: the button that starts one |
| `library.filteredTitle` | `No Notes` | a filter with no notes: its title |
| `library.filteredMessage` | `Start writing and assign a category!` | a filter with no notes: the line under it |
| `card.untitled` | `Untitled` | a card's title when the note has none |
| `card.noContent` | `No content...` | a card's text when the note has none |
| `card.changeCategory` | `Change category` | a card's menu item that files the note |
| `card.delete` | `Delete` | a card's menu item that deletes the note |
| `sheet.dismiss` | `Dismiss` | a category sheet's close button, read aloud |
| `picker.title` | `Select a Category` | the category sheet's title |
| `picker.editingTitle` | `Edit your Categories` | the category sheet's title while editing |
| `picker.edit` | `Edit` | the category sheet's button that starts editing |
| `picker.done` | `Done` | the category sheet's button that ends editing |
| `picker.all` | `All notes` | the category sheet's floating button that clears the filter |
| `picker.add` | `Create a Category` | the round button that adds a category while editing, read aloud |
| `picker.select` | `Select Category` | a category's menu item that filters by it |
| `picker.unselect` | `Unselect Category` | a category's menu item that clears its filter |
| `picker.editCategory` | `Edit Category` | a category's menu item that opens its editor |
| `picker.fileTitle` | `Change Note Category` | the sheet that files a note: its title |
| `picker.fileCreate` | `Create and assign new category` | the filing sheet's floating button |
| `picker.createTitle` | `Create a new category` | the alert that names a new category |
| `picker.namePlaceholder` | `Enter your category name` | the alert's field |
| `picker.createSave` | `Save and Assign` | the alert's button that makes the category and files the note |
| `picker.cancel` | `Cancel` | the alert's cancel button |
| `picker.createMessage` | `Your category will be created and assigned to your note.` | the alert's message |
| `category.newTitle` | `New Category` | the category editor's title for a new one |
| `category.editTitle` | `Edit Category` | the category editor's title |
| `category.namePlaceholder` | `Name your category...` | the category editor's name field |
| `category.colorLabel` | `Set the category color` | the colour well, read aloud |
| `category.cancel` | `Cancel` | the category editor's cancel button |
| `category.ok` | `Ok` | the button that drops the keyboard, read aloud |
| `category.delete` | `Delete Category` | the category editor's delete button, read aloud |
| `category.save` | `Save` | the category editor's save button |
| `category.deleteTitle` | `Confirm Category Deletion` | the dialog before a category is deleted |
| `category.deleteMessage` | `Are you sure you want to delete this category?\nAll notes in the "{name}" category will be moved to the {general} category.` | the dialog's message: {name} is the category's, {general} the general category's |
| `category.deleteConfirm` | `Yes, delete this category` | the dialog's destructive button |
| `category.deleteCancel` | `Cancel` | the dialog's cancel button |
| `category.unnamed` | `Unnamed` | a category with no name |
| `editor.bodyPlaceholder` | `What's on your mind?` | the empty text's placeholder |
| `editor.cancel` | `Cancel` | a new note's button that discards it |
| `editor.save` | `Save` | a new note's button that keeps it |
| `editor.more` | `More options` | the editor menu's label, read aloud |
| `editor.delete` | `Delete` | the editor menu's item that deletes the note |
| `editor.hideKeyboard` | `Hide keyboard` | the buttons that drop the keyboard, read aloud |
| `editor.category` | `Category: {name}.` | the category chip, read aloud; `{name}` is the category's |
| `format.title` | `Format` | the Format sheet's title |
| `format.done` | `Done` | the Format sheet's button that closes it |
| `format.style` | `Style` | the Format sheet's section of styles |
| `format.bold` | `Bold` | the bold style |
| `format.italic` | `Italic` | the italic style |
| `format.underline` | `Underlined` | the underline style |
| `format.strikethrough` | `Strikethrough` | the strikethrough style |
| `format.fontSize` | `Font Size` | the Format sheet's section of the size |
| `format.size` | `{size} pt` | the size as the Format sheet shows it: {size} is the number |
| `format.alignment` | `Alignment` | the section and pickers of alignment |
| `format.left` | `Left` | left alignment, read aloud |
| `format.center` | `Center` | centred alignment, read aloud |
| `format.right` | `Right` | right alignment, read aloud |
| `format.justified` | `Justified` | justified alignment, read aloud |
| `format.color` | `Color` | the Format sheet's section of colours |
| `format.text` | `Text` | the text colour's row |
| `format.textColor` | `Text color` | the text colour well, read aloud |
| `format.highlight` | `Highlight` | the highlight colour's row |
| `format.highlightColor` | `Highlight color` | the highlight colour well, read aloud |
| `format.undo` | `Undo` | the bar's undo button, read aloud |
| `format.redo` | `Redo` | the bar's redo button, read aloud |
| `format.smaller` | `Smaller` | the bar's smaller-size button, read aloud |
| `format.larger` | `Larger` | the bar's larger-size button, read aloud |
| `toast.noteCreated` | `Note created!` | the toast when a new note is saved |
| `toast.categoryCreated` | `Category created!` | the toast when a category is made |
| `toast.categoryAssigned` | `And assigned to your note` | the toast's second line when it is made from the filing sheet |

### Lists

| Key | Default | What it is |
| --- | --- | --- |
| `library.emptyMessages` | `What's on your mind? \| How's been your day? \| How are you feeling right now? \| It's OK. Write it down. \| Make today a little bit better. \| Let the words flow. \| Capture the moment. \| Start the symphony of thoughts.` | the grid with no notes: the line under its title, one picked |
| `editor.titlePlaceholder` | `Title your note... \| Title your imagination... \| Title your inspiration...` | the empty title's placeholder, one picked |

### Symbols

| Key | Default | What it is |
| --- | --- | --- |
| `library.more` | `ellipsis.circle` | the bar menu |
| `library.about` | `book.pages` | the bar menu's about item |
| `library.filter` | `line.3.horizontal.decrease.circle` | the filter, nothing selected |
| `library.filterOn` | `line.3.horizontal.decrease.circle.fill` | the filter, a category selected |
| `library.memories` | `brain` | the memories button, off |
| `library.memoriesOn` | `brain.fill` | the memories button, on |
| `library.new` | `plus` | the new-note button |
| `library.empty` | `note.text` | the grid with no notes |
| `library.filteredEmpty` | `pencil.and.scribble` | a filter with no notes |
| `card.changeCategory` | `arrow.forward.folder` | a card's filing item |
| `card.delete` | `trash.fill` | a card's delete item |
| `sheet.dismiss` | `xmark` | a category sheet's close button |
| `picker.off` | `circle` | a category that is not selected |
| `picker.on` | `circle.fill` | the selected category |
| `picker.edit` | `chevron.right` | a category while editing |
| `picker.add` | `plus` | the round button that adds a category |
| `picker.select` | `checkmark.circle` | a category's menu item that filters by it |
| `picker.unselect` | `xmark.circle` | a category's menu item that clears its filter |
| `picker.editCategory` | `pencil` | a category's menu item that opens its editor |
| `category.ok` | `checkmark` | the category editor's button that drops the keyboard |
| `category.delete` | `trash` | the category editor's delete button and dialog |
| `editor.more` | `ellipsis.circle` | the editor menu |
| `editor.delete` | `trash.fill` | the editor menu's delete item |
| `editor.hideKeyboard` | `chevron.down` | the bar's button that drops the keyboard |
| `format.undo` | `arrow.uturn.backward` | the formatting bar's undo |
| `format.redo` | `arrow.uturn.forward` | the formatting bar's redo |
| `format.open` | `textformat` | the formatting bar's button that opens Format |
| `format.smaller` | `minus` | a size smaller |
| `format.larger` | `plus` | a size larger |
| `format.keyboard` | `keyboard.chevron.compact.down` | the formatting bar's button that drops the keyboard |
| `format.bold` | `bold` | the bold style |
| `format.italic` | `italic` | the italic style |
| `format.underline` | `underline` | the underline style |
| `format.strikethrough` | `strikethrough` | the strikethrough style |
| `format.left` | `text.alignleft` | left alignment |
| `format.center` | `text.aligncenter` | centred alignment |
| `format.right` | `text.alignright` | right alignment |
| `format.justified` | `text.justify` | justified alignment |

### Sizes

| Key | Default | What it is |
| --- | --- | --- |
| `grid.minimum` | `160` | a grid column's least width |
| `grid.inset` | `16` | the grid's inset from the sides |
| `grid.top` | `8` | the grid's inset from the bar |
| `card.inset` | `4` | each card's inset from its column's sides |
| `card.below` | `8` | the space under each card |
| `card.padding` | `16` | a card's padding |
| `card.radius` | `16` | a card's corner radius |
| `card.border` | `1` | a card's outline |
| `card.lines` | `3` | the lines of text a card shows (whole) |
| `card.dot` | `8` | the category dot on a card |
| `empty.symbol` | `50` | an empty state's symbol |
| `empty.inset` | `42` | an empty state's line, inset from the sides |
| `empty.below` | `80` | the space under the empty grid's state |
| `filtered.below` | `60` | the space under an empty filter's state |
| `picker.minimum` | `160` | a category sheet column's least width |
| `picker.radius` | `24` | the corner radius of a category's button, the floating button and the name field |
| `picker.stroke` | `4` | the outline of a category's button, the floating buttons and the name field |
| `picker.detent` | `0.6` | the category sheets' height, a fraction of the screen |
| `category.detent` | `0.6` | the category editor's height, a fraction of the screen |
| `editor.titleSpacing` | `8` | the space above and below the title |
| `editor.titleInset` | `16` | the title's inset from the leading edge |
| `editor.textInset` | `12` | the text's inset on every side |
| `editor.chipInset` | `8` | the category chip's inset at its sides |
| `editor.chipDot` | `10` | the category chip's dot |
| `bar.height` | `50` | the formatting bar's height |
| `bar.radius` | `24` | the formatting bar's corner radius |
| `bar.inset` | `12` | the formatting bar's inset from the sides and the keyboard |
| `bar.spacing` | `15` | the space between the formatting bar's controls |
| `bar.divider` | `22` | the formatting bar's divider |
| `format.minimum` | `6` | the least font size |
| `format.maximum` | `96` | the largest font size |
| `format.step` | `1` | a font size step |

### Motion

| Key | Default | What it is |
| --- | --- | --- |
| `library.filter` | `.bouncy` | a category chosen, or the filter cleared |
| `library.delete` | `.bouncy` | a note or a category leaving |
| `picker.edit` | `.bouncy` | the category sheet going into editing and out |
| `editor.deleteDelay` | `0.6` | seconds from the editor closing to its deleted note leaving the grid |
| `category.deleteDelay` | `0.4` | seconds from the category editor closing to its deleted category leaving |

## Changes

Each change made to make this agent more precise, dated, with the run that measured it. Newest first.

### 2026-11-15 · a new note already written: `new "<title>" "<text>"`

Seer's reference `note` shot is the new-note sheet with "Launch windows" and two paragraphs on the Mars transfer
already written, the title focused at its end, not a note pushed from the grid. The launch state `new` now takes
the title and text in quotes and opens the sheet so; plain `new` and `editor <id or title>` are unchanged. The Seer
call's note destination uses it.

Measured: not yet.

### 2026-11-15 · first cut, at parity with Seer's Library and note editor

The views mirror the original's: the grid of cards under its two glass capsules, the empty states, the category
picker, filing sheet and editor, and the note editor with its formatting bar and Format sheet. The Seer call's
output builds for the iPhone simulator and the Mac in Swift 6 beside SeerKit's `Note`, and the journal example in
Swift 5 (`TESTING.md`).

Measured: not yet. The next one-shot Seer run is the first measure.
