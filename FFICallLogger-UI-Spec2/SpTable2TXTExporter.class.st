Class {
	#name : #SpTable2TXTExporter,
	#superclass : #SpTableExporter,
	#category : #'FFICallLogger-UI-Spec2'
}

{ #category : #public }
SpTable2TXTExporter >> export: aSpTablePresenter on: stream item: aTFLSignal [ 

	stream << aTFLSignal oneLineContents
]
