"
I am a Spec presenter to administrate a `TFLCallLogger`.

My collaborators are `TFLCallsPresenter` and `TFLFiltersPresenter`.

Simple example of use:
```
TFLMainPresenter open
```

More configurable example:
```
| app model presenter |
app := SpApplication new.
model := TFLCallLogger instance.
presenter := TFLMainPresenter newApplication: app model: model.
presenter openWithSpec.
```

"
Class {
	#name : #TFLMainPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'logger',
		'callsPresenter',
		'filtersPresenter'
	],
	#category : #'FFICallLogger-UI-Core'
}

{ #category : #layout }
TFLMainPresenter class >> defaultLayout [

	^ SpPanedLayout newVertical
		  positionOfSlider: 33 percent;
		  add: #filtersPresenter;
		  add: #callsPresenter;
		  yourself
]

{ #category : #convenience }
TFLMainPresenter class >> open [

	<example>
	(self on: TFLCallLogger instance) open
]

{ #category : #initialization }
TFLMainPresenter >> initializePresenters [ 

	filtersPresenter := self instantiate: TFLFiltersPresenter on: logger.
	callsPresenter := self instantiate: TFLCallsPresenter on: logger.

]

{ #category : #initialization }
TFLMainPresenter >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.

	aSpWindowPresenter
		title: 'FFI Call Logger';
		centered;
		initialExtent: 1024@640

]

{ #category : #initialization }
TFLMainPresenter >> setModelBeforeInitialization: aLogger [

	logger := aLogger
]
