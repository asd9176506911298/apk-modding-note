
class Color {
public:
    float r, b, g, a;

    Color() {
        SetColor( 0 , 0 , 0 , 255 );
    }

    Color( float r , float g , float b ) {
        SetColor( r , g , b , 255 );
    }

    Color( float r, float g, float b, float a) {
        SetColor( r , g , b , a );
    }

    void SetColor( float r1 , float g1 , float b1 , float a1 = 255 ) {
        r = r1;
        g = g1;
        b = b1;
        a = a1;
    }

    static Color Black(float a = 255){ return Color(0, 0, 0, a); }
    static Color White(float a = 255){ return Color(255 , 255 , 255, a); }
    static Color Red(float a = 255){ return Color(255 , 0 , 0, a); }
    static Color Green(float a = 255){ return Color(0 , 255 , 0, a); }
    static Color Blue(float a = 255){ return Color(0 , 0 , 255, a); }
    static Color Yellow(float a = 255){ return Color(255 , 255 , 0, a); }
    static Color Cyan(float a = 255){ return Color(0 , 255 , 255, a); }
    static Color Magenta(float a = 255){ return Color(255 , 0 , 255, a); }
};
