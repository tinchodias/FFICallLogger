"
A TFLMainPresenterTest is a test class for testing the behavior of TFLMainPresenter
"
Class {
	#name : #TFLMainPresenterTest,
	#superclass : #TestCase,
	#category : #'FFICallLogger-UI-Spec2-Tests'
}

{ #category : #tests }
TFLMainPresenterTest >> testOpen [

	| aWindow |
	aWindow := TFLMainPresenter open.
	aWindow close.
]
