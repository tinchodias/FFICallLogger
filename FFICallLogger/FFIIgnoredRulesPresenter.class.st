Class {
	#name : #FFIIgnoredRulesPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'refreshDeferrer',
		'logger',
		'toolbar',
		'list',
		'clearButton'
	],
	#category : #'FFICallLogger-UI'
}

{ #category : #specs }
FFIIgnoredRulesPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
		add: #toolbar expand: false;
		add: #list;
		yourself
]

{ #category : #initialization }
FFIIgnoredRulesPresenter >> initializeContextMenu [

	list contextMenu: [
		SpMenuPresenter new 
			addItem: [ :item |
				item
					name: 'Remove';
					action: [ logger removeIgnoreRule: list selectedItem ] ];
			yourself
		] 
]

{ #category : #initialization }
FFIIgnoredRulesPresenter >> initializePresenters [ 
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
FFIIgnoredRulesPresenter >> initializeToolbar [

	toolbar
		addItem: (clearButton := SpToolbarButtonPresenter new
			label: 'Clear ignored';
			icon: (self iconNamed: #refresh);
			action: [ logger resetIgnoreRules ];
			yourself)
]

{ #category : #accessing }
FFIIgnoredRulesPresenter >> refresh [

	list items: logger ignoreRules.
	clearButton enabled: logger ignoreRules isNotEmpty
]

{ #category : #initialization }
FFIIgnoredRulesPresenter >> setModelBeforeInitialization: aLogger [

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
