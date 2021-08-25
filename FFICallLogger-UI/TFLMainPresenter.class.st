"
I am a Spec presenter to administrate a TFLCallLogger.

My collaborators are TFLCallsPresenter and TFLFiltersPresenter.

Example:
~~~
| app model presenter |
app := SpApplication new.
model := TFLCallLogger instance.
presenter := TFLMainPresenter newApplication: app model: model.
presenter openWithSpec.
presenter window title: 'FFI Call Logger'.
~~~

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

{ #category : #specs }
TFLMainPresenter class >> defaultSpec [

	^ SpPanedLayout newVertical
		  positionOfSlider: 33 percent;
		  add: #filtersPresenter;
		  add: #callsPresenter;
		  yourself
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
		initialExtent: 1024@720

]

{ #category : #initialization }
TFLMainPresenter >> setModelBeforeInitialization: aLogger [

	logger := aLogger
]
