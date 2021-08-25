Extension { #name : #TFLCallLogger }

{ #category : #'*FFICallLogger-UI' }
TFLCallLogger >> inspectorRecordingsIn: aBuilder [
	<inspectorPresentationOrder: 0 title: 'Dashboard'>

	^ aBuilder instantiate: TFLMainPresenter on: self
]
