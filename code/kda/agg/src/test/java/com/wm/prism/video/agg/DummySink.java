// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg;

import org.apache.flink.streaming.api.functions.sink.SinkFunction;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class DummySink implements SinkFunction<Long> {

    // must be static
    public final List<Long> values = Collections.synchronizedList(new ArrayList<>());

    @Override
    public void invoke(Long value, SinkFunction.Context context) throws Exception {
        values.add(value);
    }
}
