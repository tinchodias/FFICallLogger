Class {
	#name : #SpTableExporter,
	#superclass : #Object,
	#category : #'FFICallLogger-UI-Utils'
}

{ #category : #public }
SpTableExporter >> export: aSpTablePresenter on: stream [

	aSpTablePresenter items do: [ :each |
		self export: aSpTablePresenter on: stream item: each.
		stream crlf ]

]

{ #category : #public }
SpTableExporter >> export: aSpTablePresenter on: stream item: anObject [

	self subclassResponsibility
]

{ #category : #public }
SpTableExporter >> export: aSpTablePresenter to: aFileReference [

	aFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			self export: aSpTablePresenter on: stream ]
]
