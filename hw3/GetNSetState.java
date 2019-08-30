import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSetState(int[] v) {
        value = new AtomicIntegerArray (v);
        maxval = 127;
    }

    GetNSetState(int[] v, byte m) {
        value = new AtomicIntegerArray (v);
        maxval = m;
    }

    public int size() {
        return value.length();
    }

    public byte[] current() { return null; }

    public AtomicIntegerArray currentarr() {
        return value;
    }

    public boolean swap(int i, int j) {

        int val1 = value.get(i);
        int val2 = value.get(j);

        if (val1 <= 0 || val2 >= maxval) {
            return false;
        }

        value.set(i, val1--);
        value.set(j, val2++);

        return true;
    }
}

