(**
 * Converts coordinates from SWEREF 90 to GRS 80
 *
 * For info see:
 * https://www.lantmateriet.se/globalassets/kartor-och-geografisk-information/gps-och-matning/geodesi/formelsamling/gauss_conformal_projection.pdf
 *)
let axis = 6378137.0 (* GRS 80 *)
let flattening = 1.0 /. 298.257222101 (* GRS 80. *)
let central_meridian = 15.00
let scale = 0.9996
let false_northing = 0.0
let false_easting = 500000.0
let pi = 4.0 *. atan 1.0

let to_wgs north east =
        (* Prepare ellipsoid-based stuff *)
        let e2 = flattening *. (2.0 -. flattening) in
        let n = flattening /. (2.0 -. flattening) in
        let a = axis /. (1.0 +. n) *. (1.0 +. n**2. /. 4.0 +. n**4. /. 64.0) in

        let phi1 = n /. 2.0 -. 2.0 *. n**2. /. 3.0 +. 37.0 *. n**3. /. 96.0 -. n**4. /. 360.0 in
        let phi2 = n**2. /. 48.0 +. n**3. /. 15.0 -. 437.0 *. n**4. /. 1440.0 in
        let phi3 = 17.0 *. n**3. /. 480.0 -. 37.0 *. n**4. /. 840.0 in
        let phi4 = 4397.0 *. n**4. /. 161280.0 in

        let a_star = e2 +. e2**2. +. e2**3. +. e2**4. in
        let b_star = -.(7.0 *. e2**2. +. 17.0 *. e2**3. +. 30.0 *. e2**4.) /. 6.0 in
        let c_star = (224.0 *. e2**3. +. 889.0 *. e2**4.) /. 120.0 in
        let d_star = -.(4279.0 *. e2**4.) /. 1260.0 in

        (* Convert *)
        let deg_to_rad = pi /. 180.0 in
        let lambda_zero = central_meridian *. deg_to_rad in
        let xi = (north -. false_northing) /. (scale *. a) in
        let eta = (east -. false_easting) /. (scale *. a) in
        let xi_prim = xi -.
                phi1 *. (sin (2.0 *. xi)) *. (cosh (2.0 *. eta)) -.
                phi2 *. (sin (4.0 *. xi)) *. (cosh (4.0 *. eta)) -.
                phi3 *. (sin (6.0 *. xi)) *. (cosh (6.0 *. eta)) -.
                phi4 *. (sin (8.0 *. xi)) *. (cosh (8.0 *. eta)) in
        let eta_prim = eta -.
                phi1 *. (cos (2.0 *. xi)) *. (sinh (2.0 *. eta)) -.
                phi2 *. (cos (4.0 *. xi)) *. (sinh (4.0 *. eta)) -.
                phi3 *. (cos (6.0 *. xi)) *. (sinh (6.0 *. eta)) -.
                phi4 *. (cos (8.0 *. xi)) *. (sinh (8.0 *. eta)) in
        let phi_star = asin ((sin xi_prim) /. (cosh eta_prim)) in
        let delta_lambda = atan (sinh(eta_prim) /. (cos xi_prim)) in
        let lon_radian = lambda_zero +. delta_lambda in
        let lat_radian = phi_star +. (sin phi_star) *. (cos phi_star) *.
                (a_star +.
                b_star *. ((sin phi_star) ** 2.0) +.
                c_star *. ((sin phi_star) ** 4.0) +.
                d_star *. ((sin phi_star) ** 6.0)) in
        (
            lon_radian *. 180.0 /. pi,
            lat_radian *. 180.0 /. pi
        )
