#include <assert.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

#define ROW_MIN 5
#define COLUMN_MIN 5
#define ROW_MAX 256
#define COLUMN_MAX 256

enum Code
{
    CODE_OK,
    CODE_IMG_TOO_SMALL,
    CODE_IMG_TOO_LARGE,
};

static enum Code integrate_image(
    uint16_t row, uint16_t column,
    const uint32_t src[static row * column], uint32_t dst[(row + 1) * (column + 1)]);

static enum Code integrate_image(
    const uint16_t row, const uint16_t column,
    const uint32_t src[static row * column], uint32_t dst[(row + 1) * (column + 1)])
{
#define SRC_PIXEL_AT(r, c) (src)[((r) * (column)) + (c)]
#define DST_PIXEL_AT(r, c) (dst)[((r) * (column + 1)) + (c)]
    assert(src);
    assert(dst);

    if (row < ROW_MIN || column < COLUMN_MIN)
    {
        return CODE_IMG_TOO_SMALL;
    }
    if (row > ROW_MAX || column > COLUMN_MAX)
    {
        return CODE_IMG_TOO_LARGE;
    }

    for (uint16_t r = 0; r <= row; r++)
    {
        DST_PIXEL_AT(r, 0) = 0;
    }

    for (uint16_t c = 1; c <= column; c++)
    {
        DST_PIXEL_AT(0, c) = 0;
    }

    for (uint16_t r = 1; r <= row; r++)
    {
        for (uint16_t c = 1; c <= column; c++)
        {
            DST_PIXEL_AT(r, c) =
                DST_PIXEL_AT(r - 1, c) - DST_PIXEL_AT(r - 1, c - 1) +
                DST_PIXEL_AT(r, c - 1) + SRC_PIXEL_AT(r - 1, c - 1);
        }
    }

    return CODE_OK;
#undef SRC_PIXEL_AT
#undef DST_PIXEL_AT
}

int main()
{
    const uint16_t row = 5;
    const uint16_t column = 10;
    uint32_t *const img = calloc(row * column, sizeof(*img));
    uint32_t *const result = calloc((row + 1) * (column + 1), sizeof(*result));

    for (uint32_t i = 0; i < (uint32_t)row * column; i++)
    {
        img[i] = 1;
    }

    const enum Code code = integrate_image(row, column, img, result);

    for (uint16_t r = 0; r < row + 1; r++)
    {
        for (uint16_t c = 0; c < column + 1; c++)
        {
            printf("%7" PRIu32, result[(r * (column + 1)) + c]);
        }
        printf("\n");
    }

    free(img);
    free(result);
}
