part of grid;

class Otp implements Hash {
  /**
   * Add a list of bytes to the hash computation.
   */
  void add(List<int> data);
  
  /**
   * Finish the hash computation and extract the message digest as
   * a list of bytes.
   */
  List<int> close();
  
  /**
   * Returns a new instance of this hash function.
   */
  Hash newInstance() => new Otp ();
  
  /**
   * Internal block size of the hash in bytes.
   *
   * This is exposed for use by the HMAC class which needs to know the
   * block size for the [Hash] it is using.
   */
  int get blockSize => throw new UnsupportedError('Not supported');
}