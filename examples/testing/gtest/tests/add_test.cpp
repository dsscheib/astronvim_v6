#include <gtest/gtest.h>

int add(int left, int right) { return left + right; }

TEST(Calculator, AddsTwoNumbers) { EXPECT_EQ(add(2, 3), 5); }
TEST(Calculator, AddsNegativeNumbers) { EXPECT_EQ(add(-2, -3), -5); }
