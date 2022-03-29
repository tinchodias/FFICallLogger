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
		'clearButton',
		'startButton',
		'stopButton',
		'filtersList'
	],
	#category : #'FFICallLogger-UI-Core'
}

{ #category : #layout }
TFLFiltersPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		add: #toolbar expand: false;
		add: #filtersList;
		yourself
]

{ #category : #private }
TFLFiltersPresenter >> bodyFor: aBlockClosure [

	^ aBlockClosure sourceNode body sourceCode	
]

{ #category : #actions }
TFLFiltersPresenter >> doFuelOut [

	| target |
	target := 'filters.fuel' asFileReference.
	target := target nextVersion fullName.
	logger filters serializeToFileNamed: target.
	self inform: 'Exported filters to ', target.
]

{ #category : #private }
TFLFiltersPresenter >> inform: aString [
	
	self application newInform
		title: 'Information';
		label: aString;
		parentWindow: self window;
		openDialogWithSpec

]

{ #category : #initialization }
TFLFiltersPresenter >> initializeContextMenu [

	filtersList contextMenu: [
		| selectedFilter |
		selectedFilter := filtersList selectedItem.
		
		self newMenu
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

	filtersList := self newList
		display: [ :each | self bodyFor: each ];
		whenActivatedDo: [ :selection |
			self openEditFilterDialogFor: selection selectedItem ];
		yourself.
	self initializeContextMenu.
	
	"Trigger initial refresh"
	refreshDeferrer schedule.

]

{ #category : #initialization }
TFLFiltersPresenter >> initializeToolbar [

	toolbar
		addItem: (startButton := SpToolbarButtonPresenter new
			label: 'Start';
			icon: (self iconNamed: #smallOk);
			action: [ logger start ];
			yourself);
		addItem: (stopButton := SpToolbarButtonPresenter new
			label: 'Stop';
			icon: (self iconNamed: #smallCancel);
			action: [ logger stop ];
			yourself);
		addItem: (clearButton := SpToolbarButtonPresenter new
			label: 'Clear filters';
			icon: (self iconNamed: #refresh);
			action: [ logger resetFilters ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Add Filter';
			icon: (self iconNamed: #smallAdd);
			action: [ self openAddFilterDialog ];
			yourself);
		addItemRight: (SpToolbarButtonPresenter new
			label: 'Uninstall TFLSignal';
			icon: (self iconNamed: #up);
			action: [ TFLSignal uninstall ];
			yourself);
		addItemRight: (SpToolbarButtonPresenter new
			label: 'Install TFLSignal';
			icon: (self iconNamed: #down);
			action: [ TFLSignal install ];
			yourself);
		addItemRight: (SpToolbarButtonPresenter new
			label: 'Import Fuel';
			icon: (self iconNamed: #smallSave);
			action: [ self openFuelInDialog ];
			yourself);
		addItemRight: (SpToolbarButtonPresenter new
			label: 'Export Fuel';
			icon: (self iconNamed: #smallSave);
			action: [ self doFuelOut ];
			yourself).

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

{ #category : #actions }
TFLFiltersPresenter >> openFuelInDialog [

	[ 
	| fileReferenceOrNil materializedObject |
	fileReferenceOrNil := self application
		selectFileTitle: 'Select a Fuel file with a collection of filters'.
	fileReferenceOrNil ifNil: [ ^ self ].

	[ 	materializedObject := FLMaterializer
			materializeFromFileNamed: fileReferenceOrNil pathString.
		materializedObject isCollection
			ifFalse: [ self inform: 'Serialized object was not a Collection' ]
			ifTrue: [ logger filters: materializedObject ]
	]	on: FLMaterializationError
		do: [ self inform: 'Failed to read the Fuel file' ].
	
	] fork
]

{ #category : #accessing }
TFLFiltersPresenter >> refresh [

	startButton enabled: logger isRunning not.
	stopButton enabled: logger isRunning.

	filtersList items: logger filters.
	clearButton enabled: logger filters isNotEmpty
]

{ #category : #private }
TFLFiltersPresenter >> requestFilterBody: exampleBody [

	^ self application newRequest
		  title: 'Filter';
		  label:
			  'Write the boolean criteria for "[ :signal | <criteria> ]", where True means filtering the signal. Tip: The accessors of TFLSignal are #functionName, #moduleName, #arguments, #answer.';
		  text: exampleBody;
		  openModal
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
