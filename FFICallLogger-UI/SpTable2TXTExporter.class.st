Class {
	#name : #SpTable2TXTExporter,
	#superclass : #SpTableExporter,
	#category : #'FFICallLogger-UI-Utils'
}

{ #category : #public }
SpTable2TXTExporter >> export: aSpTablePresenter on: stream item: aTFLSignal [ 

	stream << aTFLSignal oneLineContents
]
