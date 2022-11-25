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
				package: 'FFICallLogger-Tests'
					with: [ spec requires: #('FFICallLogger') ];
				package: 'FFICallLogger-UI'
					with: [ spec requires: #('FFICallLogger') ];
				package: 'FFICallLogger-UI-Tests'
					with: [ spec requires: #('FFICallLogger-UI') ];
				package: 'FFICallLogger-UI-Spec2'
					with: [ spec requires: #('FFICallLogger-UI') ];
				package: 'FFICallLogger-UI-Spec2-Tests'
					with: [ spec requires: #('FFICallLogger-UI-Spec2') ];
				yourself ]
]
