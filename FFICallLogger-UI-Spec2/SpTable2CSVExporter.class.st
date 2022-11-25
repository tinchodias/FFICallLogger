Class {
	#name : #SpTable2CSVExporter,
	#superclass : #SpTableExporter,
	#category : #'FFICallLogger-UI-Spec2'
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
