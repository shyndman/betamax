extension ListExt<E> on List<E> {
  Iterable<IndexedElement<E>> get indexed sync* {
    var i = 0;
    for (final e in this) {
      yield IndexedElement(i++, e);
    }
  }
}

class IndexedElement<E> {
  IndexedElement(this.index, this.element);
  final int index;
  final E element;
}
