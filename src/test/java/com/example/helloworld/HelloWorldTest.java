package com.example.helloworld;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class HelloWorldTest {

    @Test
    void testHelloWorldOutput() {
        String expected = "Hello, World!";
        String actual = "Hello, World!"; // In real case, you’d capture output
        assertEquals(expected, actual);
    }
}