use primitive_types::U256;

pub const WAD: U256 = U256([1_000_000_000_000_000_000, 0, 0, 0]); // 10^18
pub const HALF_WAD: U256 = U256([500_000_000_000_000_000, 0, 0, 0]); // 0.5 * 10^18

/// Multiplies two WAD numbers with rounding to nearest
pub fn mul_wad(x: U256, y: U256) -> U256 {
    if x.is_zero() || y.is_zero() {
        return U256::zero();
    }
    (x.saturating_mul(y) + HALF_WAD) / WAD
}

/// Divides two WAD numbers with rounding to nearest
pub fn div_wad(x: U256, y: U256) -> Option<U256> {
    if y.is_zero() {
        return None;
    }
    Some((x.saturating_mul(WAD) + (y / 2)) / y)
}

/// Babylonian integer square root for unscaled U256
pub fn sqrt_int(x: U256) -> U256 {
    if x.is_zero() {
        return U256::zero();
    }
    let mut z = (x + U256::one()) / 2;
    let mut y = x;
    while z < y {
        y = z;
        z = (x / z + z) / 2;
    }
    y
}

/// Fixed-point square root: sqrt(x * 1e18) returned as WAD
pub fn sqrt_wad(x: U256) -> U256 {
    if x.is_zero() {
        return U256::zero();
    }
    // Scale x by 1e18 to keep 18 decimals of precision post-square-root
    let scaled = x.saturating_mul(WAD);
    sqrt_int(scaled)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sqrt_wad() {
        // sqrt(1 * 1e18) = 1 * 1e18
        assert_eq!(sqrt_wad(WAD), WAD);

        // sqrt(4 * 1e18) = 2 * 1e18
        let four_wad = WAD * 4;
        let two_wad = WAD * 2;
        assert_eq!(sqrt_wad(four_wad), two_wad);

        // sqrt(9 * 1e18) = 3 * 1e18
        let nine_wad = WAD * 9;
        let three_wad = WAD * 3;
        assert_eq!(sqrt_wad(nine_wad), three_wad);

        // sqrt(0) = 0
        assert_eq!(sqrt_wad(U256::zero()), U256::zero());
    }

    #[test]
    fn test_mul_div_wad() {
        let two_wad = WAD * 2;
        let three_wad = WAD * 3;
        let six_wad = WAD * 6;

        assert_eq!(mul_wad(two_wad, three_wad), six_wad);
        assert_eq!(div_wad(six_wad, two_wad), Some(three_wad));
        assert_eq!(div_wad(six_wad, U256::zero()), None);
    }
}
