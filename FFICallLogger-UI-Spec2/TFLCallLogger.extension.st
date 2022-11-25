Extension { #name : #TFLCallLogger }

{ #category : #'*FFICallLogger-UI-Spec2' }
TFLCallLogger >> inspectorRecordingsIn: aBuilder [
	<inspectorPresentationOrder: 0 title: 'Dashboard'>

	^ aBuilder instantiate: TFLMainPresenter on: self
]
