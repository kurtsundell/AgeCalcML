function Age76 = MyAge76(Pb76_ratio)

if isnan(Pb76_ratio)
	Age76 = nan;
else

	ratio76 = Pb76_ratio;
	age = 500;
	age1 = 0.1;
	age2 = 5000;
	ratio1 = (1 / 137.88) * (exp(0.00098485 * age1) - 1) / (exp(0.000155125 * age1) - 1);
	ratio2 = (1 / 137.88) * (exp(0.00098485 * age2) - 1) / (exp(0.000155125 * age2) - 1);

	for j = 1:1000

	if abs((ratio1/ratio76)-1) < 0.00001
	Age76 = age1;
	break
	end

	if abs((ratio2 / ratio76) - 1) < 0.00001
	Age76 = age2;
	break
	end

	age1 = age1 + (exp(ratio76) - exp(ratio1)) * 3000;
	age2 = age2 + (exp(ratio76) - exp(ratio2)) * 3000;
	ratio1 = (1 / 137.88) * (exp(0.00098485 * age1) - 1) / (exp(0.000155125 * age1) - 1);
	ratio2 = (1 / 137.88) * (exp(0.00098485 * age2) - 1) / (exp(0.000155125 * age2) - 1);

	if abs(ratio1 - ratio76) < abs(ratio2 - ratio76)
	age2 = (age2 + age) / 2;
	age = age1;
	else
	age1 = (age1 + age) / 2;
	age = age2;
	end

	if ratio1 > 0.00001
		Age76 = nan;
	end

	end
	

end

%% ORIGINAL FUNCTION BY G. Gehrels coded in VB %%
%{
Function MyAge76(ratio67 As String) As Variant
Dim ratio76 As Double, age As Double, age1 As Double, age2 As Double, ratio1 As Double, ratio2 As Double, i As Integer
    ratio76 = 1 / Val(ratio67)
    age = 500
    age1 = 0.1
    age2 = 5000
    ratio1 = (1 / 137.88) * (Exp(0.00098485 * age1) - 1) / (Exp(0.000155125 * age1) - 1)
    ratio2 = (1 / 137.88) * (Exp(0.00098485 * age2) - 1) / (Exp(0.000155125 * age2) - 1)
    For i = 1 To 1000
        If Abs((ratio1 / ratio76) - 1) < 0.00001 Then
            MyAge76 = age1
            Exit For   '0.001%
        End If
        If Abs((ratio2 / ratio76) - 1) < 0.00001 Then
            MyAge76 = age2
            Exit For   '0.001%
        End If
        age1 = age1 + (Exp(ratio76) - Exp(ratio1)) * 3000
        age2 = age2 + (Exp(ratio76) - Exp(ratio2)) * 3000
        ratio1 = (1 / 137.88) * (Exp(0.00098485 * age1) - 1) / (Exp(0.000155125 * age1) - 1)
        ratio2 = (1 / 137.88) * (Exp(0.00098485 * age2) - 1) / (Exp(0.000155125 * age2) - 1)
        If Abs(ratio1 - ratio76) < Abs(ratio2 - ratio76) Then   'age1 is closer to target
            age2 = (age2 + age) / 2
            age = age1
        Else
            age1 = (age1 + age) / 2
            age = age2
        End If
    Next i
End Function
%}
