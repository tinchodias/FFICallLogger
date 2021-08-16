Extension { #name : #TFLCallLogger }

{ #category : #'*FFICallLogger-UI' }
TFLCallLogger >> inspectorForCallsIn: aBuilder [
	<inspectorPresentationOrder: -1 title: 'Calls'>

	^ aBuilder instantiate: TFLCallsPresenter on: self
]

{ #category : #'*FFICallLogger-UI' }
TFLCallLogger >> inspectorForFiltersIn: aBuilder [
	<inspectorPresentationOrder: -0.5 title: 'Filters'>

	^ aBuilder instantiate: TFLFiltersPresenter on: self
]
