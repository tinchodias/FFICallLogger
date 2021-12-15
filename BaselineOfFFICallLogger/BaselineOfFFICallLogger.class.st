Class {
	#name : #BaselineOfFFICallLogger,
	#superclass : #BaselineOf,
	#category : #BaselineOfFFICallLogger
}

{ #category : #baseline }
BaselineOfFFICallLogger >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				package: 'FFICallLogger';
				package: 'FFICallLogger-UI' with: [ spec requires: #('FFICallLogger') ] ]
]
