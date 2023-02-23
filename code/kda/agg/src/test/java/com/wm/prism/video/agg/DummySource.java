// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg;

import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.api.java.typeutils.ResultTypeQueryable;
import org.apache.flink.api.java.typeutils.TypeExtractor;
import org.apache.flink.streaming.api.functions.source.SourceFunction;

public class DummySource<T> implements SourceFunction<T>, ResultTypeQueryable<T> {

    private final T[] testStream;
    private final TypeInformation<T> typeInfo;

    @SuppressWarnings("unchecked")
    @SafeVarargs
    public DummySource(T... events) {
        this.testStream = events;
        this.typeInfo = (TypeInformation<T>) TypeExtractor.createTypeInfo(events[0].getClass());

    }

    @Override
    public void run(SourceContext<T> sourceContext) throws Exception {
        for (T element : testStream) {
            sourceContext.collect(element);
        }
    }

    @Override
    public void cancel() {
        // can be ignored
    }

    @Override
    public TypeInformation<T> getProducedType() {
        return typeInfo;
    }
}