//
// Created by 谢作兵 on 17/06/24.
//

#ifndef WEBF_QUALIFIED_NAME_H
#define WEBF_QUALIFIED_NAME_H

#include "foundation/webf_malloc.h"
#include "core/platform/static_constructors.h"

namespace webf {


struct QualifiedNameComponents {
  WEBF_DISALLOW_NEW();
  AtomicString* prefix_;
  AtomicString* local_name_;
  AtomicString* namespace_;
};

// This struct is used to pass data between QualifiedName and the
// QNameTranslator.  For hashing and equality only the QualifiedNameComponents
// fields are used.
struct QualifiedNameData {
  WEBF_DISALLOW_NEW();
  QualifiedNameComponents components_;
  bool is_static_;
};


// Global init routines
extern const class QualifiedName& g_any_name;
extern const class QualifiedName& g_null_name;

class QualifiedName {
  USING_FAST_MALLOC(QualifiedName);

   public:
    class QualifiedNameImpl {
     public:
      static std::shared_ptr<QualifiedNameImpl> Create(AtomicString prefix,
                                                     AtomicString local_name,
                                                     AtomicString namespace_uri,
                                                     bool is_static) {
        return std::make_shared<QualifiedNameImpl>(prefix, local_name, namespace_uri, is_static);
      }

      ~QualifiedNameImpl();

      unsigned ComputeHash() const;


      // We rely on StringHasher's HashMemory clearing out the top 8 bits when
      // doing hashing and use one of the bits for the is_static_ value.
      mutable unsigned existing_hash_ : 24;
      unsigned is_static_ : 1;
      const AtomicString prefix_;
      const AtomicString local_name_;
      const AtomicString namespace_;
      mutable AtomicString local_name_upper_;
      QualifiedNameImpl(AtomicString prefix,
                        AtomicString local_name,
                        AtomicString namespace_uri,
                        bool is_static)
          : existing_hash_(0),
            is_static_(is_static),
            prefix_(prefix),
            local_name_(local_name),
            namespace_(namespace_uri)

      {
        assert(!namespace_.IsEmpty() || namespace_.IsNull());
      }

     private:

    };

    QualifiedName(const AtomicString& prefix,
                  const AtomicString& local_name,
                  const AtomicString& namespace_uri);
    // Creates a QualifiedName instance with null prefix, the specified local
    // name, and null namespace.
    explicit QualifiedName(const AtomicString& local_name);
    ~QualifiedName();

    QualifiedName(const QualifiedName& other) = default;
    const QualifiedName& operator=(const QualifiedName& other) {
      impl_ = other.impl_;
      return *this;
    }
    QualifiedName(QualifiedName&& other) = default;
    QualifiedName& operator=(QualifiedName&& other) = default;

    bool operator==(const QualifiedName& other) const {
      return impl_ == other.impl_;
    }
    bool operator!=(const QualifiedName& other) const {
      return !(*this == other);
    }

    bool Matches(const QualifiedName& other) const {
      return impl_ == other.impl_ || (LocalName() == other.LocalName() &&
                                      NamespaceURI() == other.NamespaceURI());
    }

    bool HasPrefix() const { return impl_->prefix_ != built_in_string::knull; }
    void SetPrefix(const AtomicString& prefix) {
      *this = QualifiedName(prefix, LocalName(), NamespaceURI());
    }

    const AtomicString& Prefix() const { return impl_->prefix_; }
    const AtomicString& LocalName() const { return impl_->local_name_; }
    const AtomicString& NamespaceURI() const { return impl_->namespace_; }

    // Uppercased localName, cached for efficiency
    const AtomicString& LocalNameUpper() const {
      if (!impl_->local_name_upper_.IsNull())
        return impl_->local_name_upper_;
      return LocalNameUpperSlow();
    }

    const AtomicString& LocalNameUpperSlow() const;

    // Returns true if this is a built-in name. That is, one of the names defined
    // at build time (such as <img>).
    bool IsDefinedName() const { return impl_ && impl_->is_static_; }

    AtomicString ToString() const;

    QualifiedNameImpl* Impl() const { return impl_.get(); }

    // Init routine for globals
    static void InitAndReserveCapacityForSize(unsigned size);

    static const QualifiedName& Null() { return g_null_name; }

    // The below methods are only for creating static global QNames that need no
    // ref counting.
    static void CreateStatic(void* target_address, AtomicString* name);
    static void CreateStatic(void* target_address,
                             AtomicString* name,
                             const AtomicString& name_namespace);

   private:
//    friend struct WTF::HashTraits<blink::QualifiedName>;

    // This constructor is used only to create global/static QNames that don't
    // require any ref counting.
    QualifiedName(const AtomicString& prefix,
                  const AtomicString& local_name,
                  const AtomicString& namespace_uri,
                  bool is_static);

    std::shared_ptr<QualifiedNameImpl> impl_;
};


DEFINE_GLOBAL(QualifiedName, g_any_name);
DEFINE_GLOBAL(QualifiedName, g_null_name);

}  // namespace webf

#endif  // WEBF_QUALIFIED_NAME_H
