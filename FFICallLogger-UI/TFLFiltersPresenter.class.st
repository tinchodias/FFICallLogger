"
I am a Spec presenter to administrate the filters of a TFLCallLogger.
"
Class {
	#name : #TFLFiltersPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'refreshDeferrer',
		'logger',
		'toolbar',
		'list',
		'clearButton'
	],
	#category : #'FFICallLogger-UI-Core'
}

{ #category : #specs }
TFLFiltersPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
		add: #toolbar expand: false;
		add: #list;
		yourself
]

{ #category : #private }
TFLFiltersPresenter >> bodyFor: aBlockClosure [

	^ aBlockClosure sourceNode body sourceCode	
]

{ #category : #initialization }
TFLFiltersPresenter >> initializeContextMenu [

	list contextMenu: [
		| selectedFilter |
		selectedFilter := list selectedItem.
		
		SpMenuPresenter new 
			addItem: [ :item |
				item
					name: 'Inspect';
					action: [ selectedFilter inspect ] ];
			addItem: [ :item |
				item
					name: 'Edit';
					action: [ self openEditFilterDialogFor: selectedFilter ] ];
			addItem: [ :item |
				item
					name: 'Remove';
					action: [ logger removeFilter: selectedFilter ] ];
			yourself
		] 
]

{ #category : #initialization }
TFLFiltersPresenter >> initializePresenters [ 
	"We assume the logger was set previously."

	toolbar := self newToolbar.
	self initializeToolbar.

	list := self newList
		display: [ :each | self bodyFor: each ];
		whenActivatedDo: [ :selection | self openEditFilterDialogFor: list selectedItem ];
		yourself.
	self initializeContextMenu.
	
	"Trigger initial refresh"
	refreshDeferrer schedule.

]

{ #category : #initialization }
TFLFiltersPresenter >> initializeToolbar [

	toolbar
		addItem: (clearButton := SpToolbarButtonPresenter new
			label: 'Clear';
			icon: (self iconNamed: #refresh);
			action: [ logger resetFilters ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Add';
			icon: (self iconNamed: #smallAdd);
			action: [ self openAddFilterDialog ];
			yourself)
]

{ #category : #actions }
TFLFiltersPresenter >> openAddFilterDialog [

	(self requestFilterBody: 'signal') ifNotNil: [ :body |
		logger addFilterByCompiling: body ]
]

{ #category : #actions }
TFLFiltersPresenter >> openEditFilterDialogFor: aFilter [

	| currentBody |
	currentBody := self bodyFor: aFilter.
	(self requestFilterBody: currentBody) ifNotNil: [ :newBody | 
		logger
			addFilterByCompiling: newBody;
			removeFilter: aFilter ]
]

{ #category : #accessing }
TFLFiltersPresenter >> refresh [

	list items: logger filters.
	clearButton enabled: logger filters isNotEmpty
]

{ #category : #private }
TFLFiltersPresenter >> requestFilterBody: exampleBody [

	^ self application newRequest
		title: 'Filter';
		label:  'Write the boolean criteria for "[ :signal | <criteria> ]", where True means filtering the signal. Tip: The accessors of TFLSignal are #functionName, #moduleName, #arguments, #answer.';
		text: exampleBody;
		openModalWithSpec

]

{ #category : #initialization }
TFLFiltersPresenter >> setModelBeforeInitialization: aLogger [

	logger := aLogger.

	"We assume that deferrer won't be scheduled before the table is initialized."
	refreshDeferrer := MinMaxDeferrer
		value: (MessageSend receiver: self selector: #refresh)
		notBefore: 100 milliSeconds
		notAfter:  500 milliSeconds.

	logger announcer weak
		when: Announcement
		send: #schedule
		to: refreshDeferrer

]
