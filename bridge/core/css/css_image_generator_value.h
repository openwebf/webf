/*
* Copyright (C) 2008 Apple Inc. All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef WEBF_CORE_CSS_CSS_IMAGE_GENERATOR_VALUE_H_
#define WEBF_CORE_CSS_CSS_IMAGE_GENERATOR_VALUE_H_

#include <set>
#include "core/css/css_value.h"
#include "core/platform/gfx/geometry/size_f.h"

namespace webf {

class Document;
class Image;
class ComputedStyle;
class ImageResourceObserver;

// These maps do not contain many objects because we do not expect any
// particular CSSGeneratedImageValue to have clients at many different
// sizes at any given time.
using ImageSizeCountMap = std::unordered_set<gfx::SizeF>;
using GeneratedImageMap = std::unordered_map<gfx::SizeF, std::shared_ptr<Image>>;

//class GeneratedImageCache {
// WEBF_DISALLOW_NEW();
//
//public:
// void AddSize(const gfx::SizeF&);
// void RemoveSize(const gfx::SizeF&);
//
// Image* GetImage(const gfx::SizeF&) const;
// void PutImage(const gfx::SizeF&, scoped_refptr<Image>);
//
//private:
// // A count of how many times a given image size is in use.
// ImageSizeCountMap sizes_;
//
// // A cache of Image objects by image size.
// GeneratedImageMap images_;
//};

struct SizeAndCount {
 WEBF_DISALLOW_NEW();
 SizeAndCount() : size(), count(0) {}

 // The non-zero size associated with this client. A client must only
 // ever be present at one non-zero size, with as many zero sizes as it wants.
 gfx::SizeF size;

 // The net number of times this client has been added.
 int count;
};

using ClientSizeCountMap =
   std::unordered_map<Member<const ImageResourceObserver>, SizeAndCount>;

class CSSImageGeneratorValue : public CSSValue {
public:
// using ContainerSizes = CSSToLengthConversionData::ContainerSizes;

// void AddClient(const ImageResourceObserver*);
//
// void RemoveClient(const ImageResourceObserver*);
 // The |target_size| is the desired image size. Background images should not
 // be snapped. In other case the target size must be pixel snapped already.
// std::shared_ptr<Image> GetImage(const ImageResourceObserver&,
//                               const Document&,
//                               const ComputedStyle&,
//                               const ContainerSizes&,
//                               const gfx::SizeF& target_size);

// bool KnownToBeOpaque(const Document&, const ComputedStyle&) const;
//
// bool IsUsingCustomProperty(const AtomicString& custom_property_name,
//                            const Document&) const;
// bool IsUsingCurrentColor() const;
// bool IsUsingContainerRelativeUnits() const;

 void TraceAfterDispatch(GCVisitor*) const;

protected:
 explicit CSSImageGeneratorValue(ClassType);

// Image* GetImage(const ImageResourceObserver*, const gfx::SizeF&) const;
// void PutImage(const gfx::SizeF&, scoped_refptr<Image>) const;
// const ClientSizeCountMap& Clients() const { return clients_; }

 // A map from LayoutObjects (with entry count) to image sizes.
// mutable ClientSizeCountMap clients_;

 // Cached image instances.
// mutable GeneratedImageCache cached_images_;

 // TODO(Oilpan): when/if we can make the layoutObject point directly to the
 // CSSImageGenerator value using a member we don't need to have this hack
 // where we keep a persistent to the instance as long as there are clients in
 // the ClientSizeCountMap.
// SelfKeepAlive<CSSImageGeneratorValue> keep_alive_;
};

template <>
struct DowncastTraits<CSSImageGeneratorValue> {
 static bool AllowFrom(const CSSValue& value) {
   return value.IsImageGeneratorValue();
 }
};

}  // namespace blink

#endif  // WEBF_CORE_CSS_CSS_IMAGE_GENERATOR_VALUE_H_