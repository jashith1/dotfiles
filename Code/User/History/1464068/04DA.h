#ifndef VECTOR_H
#define VECTOR_H

#include <algorithm> // std::random_access_iterator_tag
#include <cstddef> // size_t
#include <stdexcept> // std::out_of_range
#include <type_traits> // std::is_same

template <class T>
class Vector {
public:
    class iterator;
private:
    T* array;
    size_t _capacity, _size;

    // You may want to write a function that grows the vector
    void grow() { 
        _capacity = _capacity * 2;
        if(_capacity == 0) _capacity = 1;
        T* new_array = new T[_capacity];

        for(size_t i = 0; i < _size; i++){
            new_array[i] = array[i];
        }

        delete[] array;
        array = new_array;
    }

public:
    Vector() noexcept {
        _capacity = 0;
        _size = 0;
        array = nullptr;
    }

    Vector(size_t count, const T& value) { 
        _capacity = count;
        _size = count;
        array = new T[count];
        for(size_t i = 0; i < count; i++){
            array[i] = value;
        }
    }

    explicit Vector(size_t count) { 
        _capacity = count;
        _size = count;
        array = new T[count];
        for(size_t i = 0; i < count; i++){
            array[i] = T();
        }
    }
    Vector(const Vector& other) { 
        _size = other._size;
        _capacity = other._capacity;
        array = new T[_capacity];
        for(size_t i = 0; i < _size; i++) { 
            array[i] = other.array[i];
        }
    }

    Vector(Vector&& other) noexcept {
        _size = other._size;
        _capacity = other._capacity;
        array = other.array;
        other.array = nullptr;
        other._size = 0;
        other._capacity = 0;
    }

    ~Vector() { 
        delete[] array;
    }

    Vector& operator=(const Vector& other) { 
        if(this == &other) return *this;
        delete[] array;
        _size = other._size;
        _capacity = other._capacity;
        array = new T[_capacity];
        for(size_t i = 0; i < _size; i++) { 
            array[i] = other.array[i];
        }
        return *this;
    }

    Vector& operator=(Vector&& other) noexcept { 
        if(this == &other) return *this;
        delete[] array;
        _size = other._size;
        _capacity = other._capacity;
        array = other.array;
        other.array = nullptr;
        other._size = 0;
        other._capacity = 0;
        return *this;
    }

    iterator begin() noexcept { 
        return iterator(array);
    }

    iterator end() noexcept { 
        return iterator(array + _size);
    }

    [[nodiscard]] bool empty() const noexcept { return _size == 0; }
    size_t size() const noexcept { return _size; }
    size_t capacity() const noexcept { return _capacity; }

    T& at(size_t pos) { 
        if(pos >= _size || pos < 0) throw std::out_of_range("out of range");
        return array[pos];
    }

    const T& at(size_t pos) const { 
        if(pos >= _size || pos < 0) throw std::out_of_range("out of range");
        return array[pos];
    }

    T& operator[](size_t pos) { return array[pos]; }
    const T& operator[](size_t pos) const { return array[pos]; }
    T& front() { /* TODO */ }
    const T& front() const { /* TODO */ }
    T& back() { /* TODO */ }
    const T& back() const { /* TODO */ }

    void push_back(const T& value) { 
        if(_size == _capacity) grow();
        array[_size] = value;
        _size++;
    }
    void push_back(T&& value) { 
        if(_size == _capacity) grow();
        array[_size] = value;
        _size++;
    }
    void pop_back() { /* TODO */ }

    iterator insert(iterator pos, const T& value) { /* TODO */ }
    iterator insert(iterator pos, T&& value) { /* TODO */ }
    iterator insert(iterator pos, size_t count, const T& value) { /* TODO */ }
    iterator erase(iterator pos) { /* TODO */ }
    iterator erase(iterator first, iterator last) { /* TODO */ }

    class iterator {
    public:
        using iterator_category = std::random_access_iterator_tag;
        using value_type        = T;
        using difference_type   = ptrdiff_t;
        using pointer           = T*;
        using reference         = T&;
    private:
        // Points to some element in the vector (or nullptr)
        T* _ptr;

    public:
        iterator() { _ptr = nullptr; }
        explicit iterator(T* ptr) { _ptr = ptr; }

        // This assignment operator is done for you, please do not add more
        iterator& operator=(const iterator&) noexcept = default;

        [[nodiscard]] reference operator*() const noexcept { 
            return *_ptr;
        }

        [[nodiscard]] pointer operator->() const noexcept { return _ptr; }

        // Prefix Increment: ++a
        iterator& operator++() noexcept { 
            _ptr++;
            return *this;
        }

        // Postfix Increment: a++
        iterator operator++(int) noexcept { 
            iterator temp(*this);
            _ptr++;
            return temp;
        }

        // Prefix Decrement: --a
        iterator& operator--() noexcept {
            _ptr--;
            return *this;
        }
        // Postfix Decrement: a--
        iterator operator--(int) noexcept {
            iterator temp(*this);
            _ptr--;
            return temp;
        }

        iterator& operator+=(difference_type offset) noexcept {
            _ptr += offset;
            return *this;
        }
        [[nodiscard]] iterator operator+(difference_type offset) const noexcept {
            iterator temp(*this);
            temp._ptr = temp._ptr + offset;
            return temp;
        }
        
        iterator& operator-=(difference_type offset) noexcept {
            _ptr -= offset;
            return *this;
        }
        [[nodiscard]] iterator operator-(difference_type offset) const noexcept { 
            iterator temp(*this);
            temp._ptr = temp._ptr - offset;
            return temp;
        }
        [[nodiscard]] difference_type operator-(const iterator& rhs) const noexcept { 
            return _ptr - rhs._ptr;
        }

        [[nodiscard]] reference operator[](difference_type offset) const noexcept {
            return *(_ptr + offset);
        }

        [[nodiscard]] bool operator==(const iterator& rhs) const noexcept { return _ptr == rhs._ptr; }
        [[nodiscard]] bool operator!=(const iterator& rhs) const noexcept { return _ptr != rhs._ptr; }
        [[nodiscard]] bool operator<(const iterator& rhs) const noexcept { return _ptr < rhs._ptr; }
        [[nodiscard]] bool operator>(const iterator& rhs) const noexcept { return _ptr > rhs._ptr; }
        [[nodiscard]] bool operator<=(const iterator& rhs) const noexcept { return _ptr <= rhs._ptr; }
        [[nodiscard]] bool operator>=(const iterator& rhs) const noexcept { return _ptr >= rhs._ptr; }
    };


    void clear() noexcept { 
        
    }
};

// This ensures at compile time that the deduced argument _Iterator is a Vector<T>::iterator
// There is no way we know of to back-substitute template <typename T> for external functions
// because it leads to a non-deduced context
namespace {
    template <typename _Iterator>
    using is_vector_iterator = std::is_same<typename Vector<typename _Iterator::value_type>::iterator, _Iterator>;
}

template <typename _Iterator, bool _enable = is_vector_iterator<_Iterator>::value>
[[nodiscard]] _Iterator operator+(typename _Iterator::difference_type offset, _Iterator const& iterator) noexcept { return iterator + offset; }

#endif
