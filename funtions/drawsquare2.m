function A=drawsquare2(A,x1,y1,x2,y2,id,thickness)
A=drawline(A,x1,y1,x1,y2,id,thickness);
A=drawline(A,x1,y2,x2,y2,id,thickness);
A=drawline(A,x2,y2,x2,y1,id,thickness);
A=drawline(A,x2,y1,x1,y1,id,thickness);
