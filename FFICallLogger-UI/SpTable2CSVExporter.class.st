Class {
	#name : #SpTable2CSVExporter,
	#superclass : #SpTableExporter,
	#category : #'FFICallLogger-UI-Utils'
}

{ #category : #public }
SpTable2CSVExporter >> export: aSpTablePresenter on: stream item: anObject [ 

	aSpTablePresenter columns
		do: [ :eachColumn |
			stream
				nextPut: $";
				nextPutAll: ((eachColumn readObject: anObject) copyWithout: $");
				nextPut: $" ]
		separatedBy: [ stream << ', ' ]

]
