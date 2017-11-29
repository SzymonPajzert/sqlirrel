{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
module Grammar.Print where

-- pretty-printer generated by the BNF converter

import Grammar.Abs
import Data.Char


-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : ts@(p:_) | closingOrPunctuation p -> showString t . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else ' ':s)
  closingOrPunctuation [c] = c `elem` ")],;"
  closingOrPunctuation _   = False

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)



instance Print Identifier where
  prt _ (Identifier i) = doc (showString ( i))


instance Print DelimIdent where
  prt _ (DelimIdent i) = doc (showString ( i))


instance Print DoubleString where
  prt _ (DoubleString i) = doc (showString ( i))


instance Print SingleString where
  prt _ (SingleString i) = doc (showString ( i))


instance Print FloatNum where
  prt _ (FloatNum i) = doc (showString ( i))


instance Print DoubleNum where
  prt _ (DoubleNum i) = doc (showString ( i))


instance Print OpenSet where
  prt _ (OpenSet i) = doc (showString ( i))


instance Print CloseSet where
  prt _ (CloseSet i) = doc (showString ( i))



instance Print Program where
  prt i e = case e of
    Prog querys -> prPrec i 0 (concatD [prt 0 querys])

instance Print Query where
  prt i e = case e of
    ExpQuer expression -> prPrec i 0 (concatD [prt 0 expression])
    SelQuer selectstatement -> prPrec i 0 (concatD [prt 0 selectstatement])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
instance Print Expression where
  prt i e = case e of
    OperExpr opexpr -> prPrec i 0 (concatD [prt 0 opexpr])
    CaseExpr caseexpr -> prPrec i 0 (concatD [prt 0 caseexpr])
    QuanExpr quantexpr -> prPrec i 0 (concatD [prt 0 quantexpr])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print Is where
  prt i e = case e of
    YIs -> prPrec i 0 (concatD [doc (showString "is")])
    NIs -> prPrec i 0 (concatD [doc (showString "is"), doc (showString "not")])

instance Print AfterNot where
  prt i e = case e of
    BtwnAfterNot opexpr1 opexpr2 -> prPrec i 0 (concatD [doc (showString "between"), prt 6 opexpr1, doc (showString "and"), prt 6 opexpr2])
    LikeAfterNot opexpr -> prPrec i 0 (concatD [doc (showString "like"), prt 4 opexpr])
    IsInAfterNot opexpr -> prPrec i 0 (concatD [doc (showString "in"), prt 4 opexpr])

instance Print OpExpr where
  prt i e = case e of
    PathOpExpr pathexpr -> prPrec i 14 (concatD [prt 0 pathexpr])
    ExistsOpExpr opexpr -> prPrec i 13 (concatD [doc (showString "exists"), prt 14 opexpr])
    ExponeOpExpr opexpr1 opexpr2 -> prPrec i 12 (concatD [prt 13 opexpr1, doc (showString "^"), prt 12 opexpr2])
    MultipOpExpr opexpr1 opexpr2 -> prPrec i 11 (concatD [prt 11 opexpr1, doc (showString "*"), prt 12 opexpr2])
    DivisiOpExpr opexpr1 opexpr2 -> prPrec i 11 (concatD [prt 11 opexpr1, doc (showString "/"), prt 12 opexpr2])
    ModuloOpExpr opexpr1 opexpr2 -> prPrec i 11 (concatD [prt 11 opexpr1, doc (showString "%"), prt 12 opexpr2])
    AdditiOpExpr opexpr1 opexpr2 -> prPrec i 10 (concatD [prt 10 opexpr1, doc (showString "+"), prt 11 opexpr2])
    SubstrOpExpr opexpr1 opexpr2 -> prPrec i 10 (concatD [prt 10 opexpr1, doc (showString "-"), prt 11 opexpr2])
    NegationExpr opexpr -> prPrec i 9 (concatD [doc (showString "-"), prt 11 opexpr])
    PositiveExpr opexpr -> prPrec i 9 (concatD [doc (showString "+"), prt 11 opexpr])
    ConcatOpExpr opexpr1 opexpr2 -> prPrec i 9 (concatD [prt 9 opexpr1, doc (showString "||"), prt 10 opexpr2])
    IsNullOpExpr opexpr is -> prPrec i 7 (concatD [prt 8 opexpr, prt 0 is, doc (showString "null")])
    IsMissOpExpr opexpr is -> prPrec i 7 (concatD [prt 8 opexpr, prt 0 is, doc (showString "missing")])
    IsUnknOpExpr opexpr is -> prPrec i 6 (concatD [prt 8 opexpr, prt 0 is, doc (showString "unknown")])
    IsBtwnOpExpr opexpr1 opexpr2 opexpr3 -> prPrec i 5 (concatD [prt 6 opexpr1, doc (showString "between"), prt 6 opexpr2, doc (showString "and"), prt 6 opexpr3])
    NoAfteOpExpr opexpr afternot -> prPrec i 5 (concatD [prt 6 opexpr, doc (showString "not"), prt 0 afternot])
    IsEquaOpExpr opexpr1 opexpr2 -> prPrec i 4 (concatD [prt 5 opexpr1, doc (showString "="), prt 5 opexpr2])
    NoEquaOpExpr opexpr1 opexpr2 -> prPrec i 4 (concatD [prt 5 opexpr1, doc (showString "~="), prt 5 opexpr2])
    GraterOpExpr opexpr1 opexpr2 -> prPrec i 4 (concatD [prt 5 opexpr1, doc (showString ">"), prt 5 opexpr2])
    GrOrEqOpExpr opexpr1 opexpr2 -> prPrec i 4 (concatD [prt 5 opexpr1, doc (showString ">="), prt 5 opexpr2])
    SmalerOpExpr opexpr1 opexpr2 -> prPrec i 4 (concatD [prt 5 opexpr1, doc (showString "<"), prt 5 opexpr2])
    SmOrEqOpExpr opexpr1 opexpr2 -> prPrec i 4 (concatD [prt 5 opexpr1, doc (showString "<="), prt 5 opexpr2])
    IsLikeOpExpr opexpr1 opexpr2 -> prPrec i 3 (concatD [prt 4 opexpr1, doc (showString "like"), prt 4 opexpr2])
    IsIn__OpExpr opexpr1 opexpr2 -> prPrec i 3 (concatD [prt 4 opexpr1, doc (showString "in"), prt 4 opexpr2])
    NegatiOpExp opexpr -> prPrec i 2 (concatD [doc (showString "not"), prt 3 opexpr])
    ConiunOpExp opexpr1 opexpr2 -> prPrec i 1 (concatD [prt 1 opexpr1, doc (showString "and"), prt 2 opexpr2])
    AlternOpExp opexpr1 opexpr2 -> prPrec i 0 (concatD [prt 0 opexpr1, doc (showString "or"), prt 1 opexpr2])

instance Print PathExpr where
  prt i e = case e of
    PrimaPathExp primaryexpr -> prPrec i 0 (concatD [prt 0 primaryexpr])
    FieldPathExp pathexpr variableref -> prPrec i 0 (concatD [prt 0 pathexpr, doc (showString "."), prt 0 variableref])
    INullPathExp pathexpr -> prPrec i 0 (concatD [prt 0 pathexpr, doc (showString "["), doc (showString "?"), doc (showString "]")])
    IExprPathExp pathexpr expression -> prPrec i 0 (concatD [prt 0 pathexpr, doc (showString "["), prt 0 expression, doc (showString "]")])

instance Print CaseExpr where
  prt i e = case e of
    SimpleCaseExpr expression caseexprtail -> prPrec i 0 (concatD [doc (showString "case"), prt 0 expression, prt 0 caseexprtail])
    SearchCaseExpr caseexprtail -> prPrec i 0 (concatD [doc (showString "case"), prt 0 caseexprtail])

instance Print CaseExprTail where
  prt i e = case e of
    NoElseCaseTail caseexprbinds -> prPrec i 0 (concatD [prt 0 caseexprbinds, doc (showString "end")])
    IsElseCaseTail caseexprbinds expression -> prPrec i 0 (concatD [prt 0 caseexprbinds, doc (showString "else"), prt 0 expression, doc (showString "end")])

instance Print CaseExprBind where
  prt i e = case e of
    CaseExprBind expression1 expression2 -> prPrec i 0 (concatD [doc (showString "when"), prt 0 expression1, doc (showString "then"), prt 0 expression2])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print QuantExpr where
  prt i e = case e of
    IsEndQuantExpr quantexprhelp -> prPrec i 0 (concatD [prt 0 quantexprhelp, doc (showString "end")])

instance Print QuaneExpr where
  prt i e = case e of
    NoEndQuentExpr quantexprhelp -> prPrec i 0 (concatD [prt 0 quantexprhelp])

instance Print QuantExprHelp where
  prt i e = case e of
    QuantExprHelp exprqualifier quantvariables expression -> prPrec i 0 (concatD [prt 0 exprqualifier, prt 0 quantvariables, doc (showString "satisfies"), prt 0 expression])

instance Print QuantVariable where
  prt i e = case e of
    QuantVariable variableref expression -> prPrec i 0 (concatD [prt 0 variableref, doc (showString "in"), prt 0 expression])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print ExprQualifier where
  prt i e = case e of
    SomeExprQual -> prPrec i 0 (concatD [doc (showString "some")])
    EveryExprQuar -> prPrec i 0 (concatD [doc (showString "every")])

instance Print PrimaryExpr where
  prt i e = case e of
    LiteralPrimaryExpr literal -> prPrec i 1 (concatD [prt 0 literal])
    VariablPrimaryExpr variableref -> prPrec i 1 (concatD [prt 0 variableref])
    SubquerPrimaryExpr selectstatement -> prPrec i 2 (concatD [prt 1 selectstatement])
    FunCallPrimaryExpr pathexpr expressions -> prPrec i 0 (concatD [prt 0 pathexpr, doc (showString "("), prt 0 expressions, doc (showString ")")])
    ConstruPrimaryExpr constructor -> prPrec i 1 (concatD [prt 0 constructor])

instance Print Literal where
  prt i e = case e of
    DStringLiteral doublestring -> prPrec i 0 (concatD [prt 0 doublestring])
    SStringLiteral singlestring -> prPrec i 0 (concatD [prt 0 singlestring])
    IntegeLiteral n -> prPrec i 0 (concatD [prt 0 n])
    FloatiLiteral floatnum -> prPrec i 0 (concatD [prt 0 floatnum])
    DoubleLiteral doublenum -> prPrec i 0 (concatD [prt 0 doublenum])
    NullLiteral -> prPrec i 0 (concatD [doc (showString "null")])
    MissingLiteral -> prPrec i 0 (concatD [doc (showString "missing")])
    TrueLiteral -> prPrec i 0 (concatD [doc (showString "true")])
    FalseLiteral -> prPrec i 0 (concatD [doc (showString "false")])

instance Print StringLiteral where
  prt i e = case e of
    DoubleQuoteString identifier -> prPrec i 0 (concatD [doc (showString "\""), prt 0 identifier, doc (showString "\"")])
    SingleQuoteString identifier -> prPrec i 0 (concatD [doc (showString "'"), prt 0 identifier, doc (showString "'")])

instance Print IntegerLiteral where
  prt i e = case e of
    IntegerLiteral n -> prPrec i 0 (concatD [prt 0 n])

instance Print Constructor where
  prt i e = case e of
    ArrayConstr expressions -> prPrec i 0 (concatD [doc (showString "["), prt 0 expressions, doc (showString "]")])
    MultisetConst openset expressions closeset -> prPrec i 0 (concatD [prt 0 openset, prt 0 expressions, prt 0 closeset])
    ObjectConstr fieldbindings -> prPrec i 0 (concatD [doc (showString "{"), prt 0 fieldbindings, doc (showString "}")])

instance Print FieldBinding where
  prt i e = case e of
    FieldBinding expression1 expression2 -> prPrec i 0 (concatD [prt 0 expression1, doc (showString ":"), prt 0 expression2])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print SelectStatement where
  prt i e = case e of
    SelectStmt mwithclause selsetoper morder mlimitclause -> prPrec i 0 (concatD [prt 0 mwithclause, prt 0 selsetoper, prt 0 morder, prt 0 mlimitclause])

instance Print SelSetOper where
  prt i e = case e of
    SelSetOper selectblock unionedsetss -> prPrec i 0 (concatD [prt 0 selectblock, prt 0 unionedsetss])

instance Print UnionedSets where
  prt i e = case e of
    SelBlockUnionedSets selectblock -> prPrec i 0 (concatD [doc (showString "union"), doc (showString "all"), prt 0 selectblock])
    SubqueryUnionedSets selectstatement -> prPrec i 0 (concatD [doc (showString "union"), doc (showString "all"), prt 1 selectstatement])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print SelectBlock where
  prt i e = case e of
    FirstSelBlock selclause mfromdefval mwhere mgroup morder mdefval mhaving -> prPrec i 0 (concatD [prt 0 selclause, prt 0 mfromdefval, prt 0 mwhere, prt 0 mgroup, prt 0 morder, prt 0 mdefval, prt 0 mhaving])
    SeconSelBlock fromclause mdefval1 mwhere mgroup morder mdefval2 mhaving selclause -> prPrec i 0 (concatD [prt 0 fromclause, prt 0 mdefval1, prt 0 mwhere, prt 0 mgroup, prt 0 morder, prt 0 mdefval2, prt 0 mhaving, prt 0 selclause])

instance Print MFromDefVal where
  prt i e = case e of
    IsMFromDefVal fromclause mdefval -> prPrec i 0 (concatD [prt 0 fromclause, prt 0 mdefval])
    NoMFromDefVal -> prPrec i 0 (concatD [])

instance Print MWhere where
  prt i e = case e of
    IsMWhere whereclause -> prPrec i 0 (concatD [prt 0 whereclause])
    NoMWhere -> prPrec i 0 (concatD [])

instance Print MGroupDefValHaving where
  prt i e = case e of
    IsMGroupDefValHaving groupbyclause mdefval mhaving -> prPrec i 0 (concatD [prt 0 groupbyclause, prt 0 mdefval, prt 0 mhaving])
    NoMGroupDefValHaving -> prPrec i 0 (concatD [])

instance Print MDefVal where
  prt i e = case e of
    LetMDefVal letclause -> prPrec i 0 (concatD [prt 0 letclause])
    WitMDefVal withclause -> prPrec i 0 (concatD [prt 0 withclause])
    NonMDefVal -> prPrec i 0 (concatD [])

instance Print SelClause where
  prt i e = case e of
    SelClause mtypeselclause selregorval -> prPrec i 0 (concatD [doc (showString "select"), prt 0 mtypeselclause, prt 0 selregorval])

instance Print SelRegOrVal where
  prt i e = case e of
    RegSelRegOrVal selreg -> prPrec i 0 (concatD [prt 0 selreg])
    ValSelRegOrVal selval -> prPrec i 0 (concatD [prt 0 selval])

instance Print MTypeSelClause where
  prt i e = case e of
    AllMTypeSelClause -> prPrec i 0 (concatD [doc (showString "all")])
    DisMTypeSelClause -> prPrec i 0 (concatD [doc (showString "distinct")])
    NonMTypeSelClause -> prPrec i 0 (concatD [])

instance Print SelReg where
  prt i e = case e of
    SelReg projections -> prPrec i 0 (concatD [prt 0 projections])

instance Print SelValType where
  prt i e = case e of
    ValueSelValType -> prPrec i 0 (concatD [doc (showString "value")])
    ElemtSelValType -> prPrec i 0 (concatD [doc (showString "element")])
    Raw__SelValType -> prPrec i 0 (concatD [doc (showString "raw")])

instance Print SelVal where
  prt i e = case e of
    SelVal selvaltype expression -> prPrec i 0 (concatD [prt 0 selvaltype, prt 0 expression])

instance Print Projection where
  prt i e = case e of
    AllProjection -> prPrec i 0 (concatD [doc (showString "*")])
    ExpProjection expression masidentifier -> prPrec i 0 (concatD [prt 0 expression, prt 0 masidentifier])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print MAsIdentifier where
  prt i e = case e of
    NoMAsIdent -> prPrec i 0 (concatD [])
    IsMAsIdent mas identifier -> prPrec i 0 (concatD [prt 0 mas, prt 0 identifier])

instance Print MAs where
  prt i e = case e of
    NoMAs -> prPrec i 0 (concatD [])
    IsMAs -> prPrec i 0 (concatD [doc (showString "as")])

instance Print FromClause where
  prt i e = case e of
    FromClause fromterms -> prPrec i 0 (concatD [doc (showString "from"), prt 0 fromterms])

instance Print FromTerm where
  prt i e = case e of
    FromTerm exprmvarmat fromtermjoins -> prPrec i 0 (concatD [prt 0 exprmvarmat, prt 0 fromtermjoins])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print FromTermJoin where
  prt i e = case e of
    FromTermJoin mjointype joinorunnest -> prPrec i 0 (concatD [prt 0 mjointype, prt 0 joinorunnest])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print JoinOrUnnest where
  prt i e = case e of
    JoinJoinOrUnnest exprmvarmat expression -> prPrec i 0 (concatD [doc (showString "join"), prt 0 exprmvarmat, doc (showString "on"), prt 0 expression])
    UnnrJoinOrUnnest unnestclausetype expression mas variable matvar -> prPrec i 0 (concatD [prt 0 unnestclausetype, prt 0 expression, prt 0 mas, prt 0 variable, prt 0 matvar])

instance Print ExprMVarMAt where
  prt i e = case e of
    ExprMVar expression mmasvar matvar -> prPrec i 0 (concatD [prt 0 expression, prt 0 mmasvar, prt 0 matvar])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print MMAsVar where
  prt i e = case e of
    NoMMAsVar -> prPrec i 0 (concatD [])
    IsMMAsVar mas variable -> prPrec i 0 (concatD [prt 0 mas, prt 0 variable])

instance Print UnnestClauseType where
  prt i e = case e of
    UnnestUnnestClauseType -> prPrec i 0 (concatD [doc (showString "unnest")])
    CorrelUnnestClauseType -> prPrec i 0 (concatD [doc (showString "correlate")])
    FlatteUnnestClauseType -> prPrec i 0 (concatD [doc (showString "flatten")])

instance Print MAtVar where
  prt i e = case e of
    IsMAtVar variable -> prPrec i 0 (concatD [doc (showString "at"), prt 0 variable])
    NoMAtVar -> prPrec i 0 (concatD [])

instance Print MJoinType where
  prt i e = case e of
    IsMJoinType jointype -> prPrec i 0 (concatD [prt 0 jointype])
    NoMJoinType -> prPrec i 0 (concatD [])

instance Print JoinType where
  prt i e = case e of
    InnerJoinType -> prPrec i 0 (concatD [doc (showString "inner")])
    LeftNJoinType -> prPrec i 0 (concatD [doc (showString "left")])
    LeftIJoinType -> prPrec i 0 (concatD [doc (showString "left"), doc (showString "outer")])

instance Print WithClause where
  prt i e = case e of
    WithClause withelements -> prPrec i 0 (concatD [doc (showString "with"), prt 0 withelements])

instance Print MWithClause where
  prt i e = case e of
    IsMWithClause withclause -> prPrec i 0 (concatD [prt 0 withclause])
    NoMWithClause -> prPrec i 0 (concatD [])

instance Print LetClause where
  prt i e = case e of
    LetClause letletclause letelements -> prPrec i 0 (concatD [prt 0 letletclause, prt 0 letelements])

instance Print LetLetClause where
  prt i e = case e of
    FirstLetLetClause -> prPrec i 0 (concatD [doc (showString "let")])
    SeconLetLetClause -> prPrec i 0 (concatD [doc (showString "letting")])

instance Print LetElement where
  prt i e = case e of
    LetElement variable expression -> prPrec i 0 (concatD [prt 0 variable, doc (showString "="), prt 0 expression])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print WithElement where
  prt i e = case e of
    WithElement variable expression -> prPrec i 0 (concatD [prt 0 variable, doc (showString "as"), prt 0 expression])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print WhereClause where
  prt i e = case e of
    WhereClause expression -> prPrec i 0 (concatD [doc (showString "where"), prt 0 expression])

instance Print GroupbyClause where
  prt i e = case e of
    GroupbyClause exprmvarmats maybegroupas -> prPrec i 0 (concatD [doc (showString "group"), doc (showString "by"), prt 0 exprmvarmats, prt 0 maybegroupas])

instance Print MGroup where
  prt i e = case e of
    IsMGroup groupbyclause -> prPrec i 0 (concatD [prt 0 groupbyclause])
    NoMGroup -> prPrec i 0 (concatD [])

instance Print MaybeGroupAs where
  prt i e = case e of
    IsMaybeGroupAs variable maybevarasref -> prPrec i 0 (concatD [doc (showString "group"), doc (showString "as"), prt 0 variable, prt 0 maybevarasref])
    NoMaybeGroupAs -> prPrec i 0 (concatD [])

instance Print MaybeVarAsRef where
  prt i e = case e of
    IsMaybeVarAsRef varasrefs -> prPrec i 0 (concatD [doc (showString "("), prt 0 varasrefs, doc (showString ")")])
    NoMaybeVarAsRef -> prPrec i 0 (concatD [])

instance Print VarAsRef where
  prt i e = case e of
    VarAsRef variable variableref -> prPrec i 0 (concatD [prt 0 variable, doc (showString "as"), prt 0 variableref])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print HavingClause where
  prt i e = case e of
    HavingClause expression -> prPrec i 0 (concatD [doc (showString "having"), prt 0 expression])

instance Print MHaving where
  prt i e = case e of
    IsMHaving havingclause -> prPrec i 0 (concatD [prt 0 havingclause])
    NoMHaving -> prPrec i 0 (concatD [])

instance Print MOrder where
  prt i e = case e of
    IsMOrder orderby -> prPrec i 0 (concatD [prt 0 orderby])
    NoMOrder -> prPrec i 0 (concatD [])

instance Print OrderBy where
  prt i e = case e of
    OrderBy exprorderbyclauses -> prPrec i 0 (concatD [doc (showString "order"), doc (showString "by"), prt 0 exprorderbyclauses])

instance Print ExprOrderbyClause where
  prt i e = case e of
    ExprOrderByClause expression maybeordorderbyclause -> prPrec i 0 (concatD [prt 0 expression, prt 0 maybeordorderbyclause])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print MaybeOrdOrderbyClause where
  prt i e = case e of
    AscOrdClause -> prPrec i 0 (concatD [doc (showString "asc")])
    DesOrdClause -> prPrec i 0 (concatD [doc (showString "desc")])
    NonOrdClause -> prPrec i 0 (concatD [])

instance Print MLimitClause where
  prt i e = case e of
    IsMLimitClause limitclause -> prPrec i 0 (concatD [prt 0 limitclause])
    NoMLimitClause -> prPrec i 0 (concatD [])

instance Print LimitClause where
  prt i e = case e of
    LimitClause expression moffsetexpr -> prPrec i 0 (concatD [doc (showString "limit"), prt 0 expression, prt 0 moffsetexpr])

instance Print MOffsetExpr where
  prt i e = case e of
    IsMOffsetExpr expression -> prPrec i 0 (concatD [doc (showString "offset"), prt 0 expression])
    NoMOffsetExpr -> prPrec i 0 (concatD [])

instance Print VariableRef where
  prt i e = case e of
    VariableRef identifier -> prPrec i 0 (concatD [prt 0 identifier])
    QualifieRef delimident -> prPrec i 0 (concatD [prt 0 delimident])

instance Print Variable where
  prt i e = case e of
    Variable identifier -> prPrec i 0 (concatD [prt 0 identifier])

