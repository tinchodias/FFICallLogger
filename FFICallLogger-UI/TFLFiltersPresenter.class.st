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

{ #category : #initialization }
TFLFiltersPresenter >> initializeContextMenu [

	list contextMenu: [
		SpMenuPresenter new 
			addItem: [ :item |
				item
					name: 'Remove';
					action: [ logger removeFilter: list selectedItem ] ];
			yourself
		] 
]

{ #category : #initialization }
TFLFiltersPresenter >> initializePresenters [ 
	"We assume the logger was set previously."

	toolbar := self newToolbar.
	self initializeToolbar.

	list := self newList.
"	table display:[:each | each ]"
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

{ #category : #initialization }
TFLFiltersPresenter >> openAddFilterDialog [

	| conditionString sourceCode blockWithCondition |
	conditionString := self application newRequest
		title: 'Add Filter';
		label: 'Write the boolean condition for "[ :signal | <condition> ]". True means filter the signal. Accessors: #functionName, #moduleName, #arguments, #answer. Browse TFLSignal for more information.';
		text: 'signal';
		openModalWithSpec.
	conditionString ifNil: [ ^ self ].
	sourceCode := '[ :signal | {1} ]' format: { conditionString }.
	blockWithCondition := self class compiler evaluate: sourceCode. 
	logger addFilter: blockWithCondition
]

{ #category : #accessing }
TFLFiltersPresenter >> refresh [

	list items: logger filters.
	clearButton enabled: logger filters isNotEmpty
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
