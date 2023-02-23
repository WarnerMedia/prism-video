// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.examples;

import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class TestingTests {
    @Test
    public void testTesting() {

        assertTrue(true);
    }

    @Test
    public void testCollection() throws Exception {
        CollectSink sink1 = new CollectSink();
        CollectSink sink2 = new CollectSink();

        sink1.values.clear();
        sink1.invoke(1L, null);

        assertEquals("Lists will share inner data", 1, sink2.values.size());
    }

    // create a testing sink
    private static class CollectSink implements SinkFunction<Long> {

        // must be static
        public static final List<Long> values = Collections.synchronizedList(new ArrayList<>());

        @Override
        public void invoke(Long value, Context context) throws Exception {
            values.add(value);
        }
    }
}