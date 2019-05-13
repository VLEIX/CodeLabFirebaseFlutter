abstract class DAO<T> {
  T get(int index);
  List<T> getAll();
  void add(T t);
  void update(T t);
  void delete(T t);
}